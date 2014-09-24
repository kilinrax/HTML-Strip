
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "strip_html.h"

MODULE = HTML::Strip		PACKAGE = HTML::Strip

PROTOTYPES: ENABLE

Stripper *
create()
 PREINIT:
  Stripper * stripper;
 CODE:
  New( 0, stripper, 1, Stripper );
  reset( stripper );
  RETVAL = stripper;
 OUTPUT:
  RETVAL

void
DESTROY( stripper )
  Stripper * stripper
 CODE:
  Safefree( stripper );

char *
strip_html( stripper, raw )
  Stripper * stripper
  char * raw
 PREINIT:
  char * clean;
  int size = strlen(raw) + 1;
 INIT:
  New( 0, clean, size, char );
 CODE:
  strip_html( stripper, raw, clean );
  RETVAL = clean;
 OUTPUT:
  RETVAL
 CLEANUP:
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
