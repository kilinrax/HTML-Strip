use Test::More tests => 3;

BEGIN { use_ok 'HTML::Strip' }

{
  my $hs = HTML::Strip->new( filter => undef );
  ok( $hs->parse( '<html>&nbsp;</html>' ), '&nbsp;' );
  $hs->eof;

}

{
  my $filter = sub { my $s = shift; $s =~ s/\s/ /g;; $s };
  my $hs = HTML::Strip->new( filter => $filter );
  ok( $hs->parse( "<html>title\ntext\ntext</html>" ), 'title text text' );
  $hs->eof;

}
