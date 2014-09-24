use Test::More tests => 6;

BEGIN { use_ok 'HTML::Strip' }

{
  # set_striptags( \@ARRAY )
  my $hs = HTML::Strip->new;
  $hs->set_striptags( [ 'foo' ] );

  is( $hs->parse( '<script>foo</script>bar' ), 'foo bar', 'set_striptags redefinition works' );
  $hs->eof;

  is( $hs->parse( '<foo>foo</foo>bar' ), 'bar', 'set_striptags redefinition works' );
  $hs->eof;
}

{
  # set_striptags( LIST )
  my @striptags = qw(baz quux);
  my $hs = HTML::Strip->new;
  $hs->set_striptags( @striptags );

  is( $hs->parse( '<baz>fumble</baz>bar<quux>foo</quux>' ), 'bar', 'stripping user-defined tags ok' );
  $hs->eof;

  is( $hs->parse( '<baz>fumble<quux/>foo</baz>bar' ), 'bar', 'stripping user-defined tags ok' );
  $hs->eof;

  is( $hs->parse( '<foo> </foo> <bar> baz </bar>' ), '   baz ', 'stripping user-defined tags ok' );
  $hs->eof;
}
