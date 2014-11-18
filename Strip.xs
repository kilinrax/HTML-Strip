
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <unicode/ustring.h>
#include "strip_html.h"

MODULE = HTML::Strip		PACKAGE = HTML::Strip

PROTOTYPES: ENABLE

Stripper *
create()
 PREINIT:
  Stripper * stripper;
 CODE:
  Newx( stripper, 1, Stripper );
  reset( stripper );
  RETVAL = stripper;
 OUTPUT:
  RETVAL

void
DESTROY( stripper )
  Stripper * stripper
 CODE:
  Safefree( stripper );

SV *
strip_html( stripper, raw )
  Stripper *    stripper
  char *        raw
 PREINIT:
  UErrorCode    u_error = U_ZERO_ERROR;
  UChar *       u_raw;
  UChar *       u_clean;
  char *        clean;
  int size = strlen(raw)+1;
 INIT:
  Newx( u_raw,   size,  UChar );
  Newx( u_clean, size,  UChar );
  Newx( clean,   size,  char);
  u_strFromUTF8( u_raw, size, NULL, raw, -1, &u_error );
 CODE:
  strip_html( stripper, u_raw, u_clean );
  u_strToUTF8( clean, size, NULL, u_clean, -1, &u_error );
  RETVAL = newSVpv(clean, strlen(clean));
  SvUTF8_on(RETVAL);
 OUTPUT:
  RETVAL
 CLEANUP:
  Safefree( u_raw );
  Safefree( u_clean );
  Safefree( clean );

void
reset( stripper )
  Stripper * stripper

void
clear_striptags( stripper )
  Stripper * stripper

void
add_striptag( stripper, tag )
  Stripper * stripper
  char * tag

void
set_emit_spaces( stripper, emit )
  Stripper * stripper
  int emit
 CODE:
  stripper->o_emit_spaces = emit;

void
set_decode_entities( stripper, decode )
  Stripper * stripper
  int decode
 CODE:
  stripper->o_decode_entities = decode;

int
decode_entities( stripper )
  Stripper * stripper
 CODE:
  RETVAL = stripper->o_decode_entities;
 OUTPUT:
  RETVAL

void
set_striptags_ref( stripper, tagref )
  Stripper * stripper
  SV * tagref
 PREINIT:
  AV * tags;
  I32 numtags = 0;
  int n;
  if( (SvROK(tagref)) &&
      (SvTYPE(SvRV(tagref)) == SVt_PVAV) ) {
    tags = (AV *) SvRV(tagref);
  } else {
    XSRETURN_UNDEF;
  }
  numtags = av_len(tags);
  if( numtags < 0 ) {
    XSRETURN_UNDEF;
  }
 CODE:
  clear_striptags( stripper );
  for (n = 0; n <= numtags; n++) {
     STRLEN l;
     char * tag = SvPV(*av_fetch(tags, n, 0), l);
     add_striptag( stripper, tag );
  }

void
set_auto_reset( stripper, value )
  Stripper * stripper
  int value
 CODE:
  stripper->o_auto_reset = value;

int
auto_reset( stripper )
  Stripper * stripper
 CODE:
  RETVAL = stripper->o_auto_reset;
 OUTPUT:
  RETVAL

void
set_debug( stripper, value )
  Stripper * stripper
  int value
 CODE:
  stripper->o_debug = value;

int
debug( stripper )
  Stripper * stripper
 CODE:
  RETVAL = stripper->o_debug;
 OUTPUT:
  RETVAL
