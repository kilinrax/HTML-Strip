
use Test::More tests => 5;

BEGIN { use_ok 'HTML::Strip' }

{
  my $hs = HTML::Strip->new; # auto_reset off by default
  my $o = $hs->parse( "<html>\nTitle\n<script>a+b\n" );
  is( $o, "\nTitle\n" );
  my $o2 = $hs->parse( "c+d\n</script>\nEnd\n</html>" );
  is( $o2, "\nEnd\n" );
}

{
  my $hs = HTML::Strip->new( auto_reset => 1 ); # auto_reset on
  my $o = $hs->parse( "<html>\nTitle\n<script>a+b\n" );
  is( $o, "\nTitle\n" );
  my $o2 = $hs->parse( "c+d\n</script>\nEnd\n</html>" );
  is( $o2, "c+d\n\nEnd\n" );
}
