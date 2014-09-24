#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "strip_html.h"

void
strip_html( Stripper * stripper, const char * raw, char * output ) {
  const char * p_raw = raw;
  const char * raw_end = raw + strlen(raw);
  char * p_output = output;

  while( p_raw < raw_end ) {
    if( stripper->o_debug ) {
      printf( "[DEBUG] char %c state %c %c %c tag:%5s, %c %c %c %c, %c %c %c %c:%c, ",
        *p_raw,
        (stripper->f_closing ? 'C' : ' '),
        (stripper->f_in_tag ? 'T' : ' '),
        (stripper->f_full_tagname ? 'F' : ' '),
        stripper->tagname,
        (stripper->f_just_seen_tag ? 'J' : ' '),
        (stripper->f_outputted_space ? 'S' : ' '),
        (stripper->f_lastchar_slash ? '/' : ' '),
        (stripper->f_lastchar_minus ? '-' : ' '),
        (stripper->f_in_decl ? 'D' : ' '),
        (stripper->f_in_comment ? 'C' : ' '),
        (stripper->f_in_striptag ? 'X' : ' '),
        (stripper->f_in_quote ? 'Q' : ' '),
        (stripper->quote ? stripper->quote : ' ')
      );
    }
    if( stripper->f_in_tag ) {
      /* inside a tag */
      /* check if we know either the tagname, or that we're in a declaration */
      if( !stripper->f_full_tagname && !stripper->f_in_decl ) {
        /* if this is the first character, check if it's a '!'; if so, we're in a declaration */
        if( stripper->p_tagname == stripper->tagname && *p_raw == '!' ) {
          stripper->f_in_decl = 1;
        }
        /* then check if the first character is a '/', in which case, this is a closing tag */
        else if( stripper->p_tagname == stripper->tagname && *p_raw == '/' ) {
          stripper->f_closing = 1;
        /* we only care about closing tags within a stripped tags block (e.g. scripts) */
        } else if( !stripper->f_in_striptag || stripper->f_closing ) {
          /* if we don't have the full tag name yet, add current character unless it's whitespace, a '/', or a '>';
             otherwise null pad the string and set the full tagname flag, and check the tagname against stripped ones.
             also sanity check we haven't reached the array bounds, and truncate the tagname here if we have */
          if( (!isspace( *p_raw ) && *p_raw != '/' && *p_raw != '>') &&
              !( (stripper->p_tagname - stripper->tagname) == MAX_TAGNAMELENGTH ) ) {
            *stripper->p_tagname++ = *p_raw;
          } else {
            *stripper->p_tagname = 0;
            stripper->f_full_tagname = 1;
            /* if we're in a stripped tag block, and this is a closing tag, check to see if it ends the stripped block */
            if( stripper->f_in_striptag && stripper->f_closing ) {
              if( strcasecmp( stripper->tagname, stripper->striptag ) == 0 ) {
                stripper->f_in_striptag = 0;
              }
              /* if we're outside a stripped tag block, check tagname against stripped tag list */
            } else if( !stripper->f_in_striptag && !stripper->f_closing ) {
              int i;
              for( i = 0; i < stripper->numstriptags; i++ ) {
                if( strcasecmp( stripper->tagname, stripper->o_striptags[i] ) == 0 ) {
                  stripper->f_in_striptag = 1;
                  strcpy( stripper->striptag, stripper->tagname );
                }
              }
            }
            check_end( stripper, *p_raw );
          }
        }
      } else {
        if( stripper->f_in_quote ) {
          /* inside a quote */
          /* end of quote if current character matches the opening quote character */
          if( *p_raw == stripper->quote ) {
            stripper->quote = 0;
            stripper->f_in_quote = 0;
          }
        } else {
          /* not in a quote */
          /* check for quote characters, but not in a comment */
          if( !stripper->f_in_comment &&
              ( *p_raw == '\'' || *p_raw == '\"' ) ) {
            stripper->f_in_quote = 1;
            stripper->quote = *p_raw;
            /* reset lastchar_* flags in case we have something perverse like '-"' or '/"' */
            stripper->f_lastchar_minus = 0;
            stripper->f_lastchar_slash = 0;
          } else {
            if( stripper->f_in_decl ) {
              /* inside a declaration */
              if( stripper->f_lastchar_minus ) {
                /* last character was a minus, so if current one is, then we're either entering or leaving a comment */
                if( *p_raw == '-' ) {
                  stripper->f_in_comment = !stripper->f_in_comment;
                }
                stripper->f_lastchar_minus = 0;
              } else {
                /* if current character is a minus, we might be starting a comment marker */
                if( *p_raw == '-' ) {
                  stripper->f_lastchar_minus = 1;
                }
              }
              if( !stripper->f_in_comment ) {
                check_end( stripper, *p_raw );
              }
            } else {
              check_end( stripper, *p_raw );
            }
          } /* quote character check */
        } /* in quote check */
      } /* full tagname check */
    }
    else {
      /* not in a tag */
      /* check for tag opening, and reset parameters if one has */
      if( *p_raw == '<' ) {
        stripper->f_in_tag = 1;
        stripper->tagname[0] = 0;
        stripper->p_tagname = stripper->tagname;
        stripper->f_full_tagname = 0;
        stripper->f_closing = 0;
        stripper->f_just_seen_tag = 1;
      }
      else {
        /* copy to stripped provided we're not in a stripped block */
        if( !stripper->f_in_striptag ) {
          /* only emit spaces if we're configured to do so (on by default) */
          if( stripper->o_emit_spaces ){
            /* output a space in place of tags we have previously parsed,
               and set a flag so we only do this once for every group of tags.
               done here to prevent unnecessary trailing spaces */
            if( !isspace(*p_raw) &&
              /* don't output a space if this character is one anyway */
                !stripper->f_outputted_space &&
                stripper->f_just_seen_tag ) {
              if( stripper->o_debug ) {
                printf("SPACE ");
              }
              *p_output++ = ' ';
              stripper->f_outputted_space = 1;
            }
          }
          if( stripper->o_debug ) {
            printf("CHAR %c", *p_raw);
          }
          *p_output++ = *p_raw;
          /* reset 'just seen tag' flag */
          stripper->f_just_seen_tag = 0;
          /* reset 'outputted space' flag if character is not one */
          if (!isspace(*p_raw)) {
            stripper->f_outputted_space = 0;
          } else {
            stripper->f_outputted_space = 1;
          }
        }
      }
    } /* in tag check */
    p_raw++;
    if( stripper->o_debug ) {
      printf("\n");
    }
  } /* while loop */

  *p_output = 0;

  if (stripper->o_auto_reset) {
    reset( stripper );
  }
}

void
reset( Stripper * stripper ) {
  stripper->f_in_tag = 0;
  stripper->f_closing = 0;
  stripper->f_lastchar_slash = 0;
  stripper->f_full_tagname = 0;
  /* hack to stop a space being output on strings starting with a tag */
  stripper->f_outputted_space = 1;
  stripper->f_just_seen_tag = 0;

  stripper->f_in_quote = 0;

  stripper->f_in_decl = 0;
  stripper->f_in_comment = 0;
  stripper->f_lastchar_minus = 0;

  stripper->f_in_striptag = 0;

}

void
clear_striptags( Stripper * stripper ) {
  strcpy(stripper->o_striptags[0], "");
  stripper->numstriptags = 0;
}

void
add_striptag( Stripper * stripper, char * striptag ) {
  if( stripper->numstriptags < MAX_STRIPTAGS-1 ) {
    strcpy(stripper->o_striptags[stripper->numstriptags++], striptag);
  } else {
    fprintf( stderr, "Cannot have more than %i strip tags", MAX_STRIPTAGS );
  }
}

#ifdef _MSC_VER
#define strcasecmp(a,b) stricmp(a,b)
#endif

void
check_end( Stripper * stripper, char end ) {
  /* if current character is a slash, may be a closed tag */
  if( end == '/' ) {
    stripper->f_lastchar_slash = 1;
  } else {
    /* if the current character is a '>', then the tag has ended */
    if( end == '>' ) {
      stripper->f_in_quote = 0;
      stripper->f_in_comment = 0;
      stripper->f_in_decl = 0;
      stripper->f_in_tag = 0;
      /* Do not start a stripped tag block if the tag is a closed one, e.g. '<script src="foo" />' */
      if( stripper->f_lastchar_slash &&
          (strcasecmp( stripper->striptag, stripper->tagname ) == 0) ) {
        stripper->f_in_striptag = 0;
      }
    }
    stripper->f_lastchar_slash = 0;
  }
}
