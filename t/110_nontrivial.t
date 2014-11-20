use Test::More tests => 10;

use HTML::Strip;

my $hs = HTML::Strip->new();

is( $hs->parse( '<p align="center>test</p>' ), '', '"works" with non-terminated quotes' );
$hs->eof;

is( $hs->parse( '<img src="foo.gif" alt="a > b">bar' ), 'bar', 'works with quote attributes which contain >' );
$hs->eof;

is( $hs->parse( '<script> if (a>b && a<c) { ... } </script>bar' ), 'bar', '<script> tag and content are stripped' );
$hs->eof;

is( $hs->parse( '<# just data #>bar' ), 'bar', 'weird tags get stripped' );
$hs->eof;

is( $hs->parse( '<script>foo</script>bar' ), 'bar', '<script> nodes are stripped ("script" is a default strip_tag)' );
$hs->eof;

my $has_html_entities = eval { require HTML::Entities; 1 };
SKIP: {
    skip 'HTML::Entities not available', 4 unless $has_html_entities;

    is( $hs->parse( '&#060;foo&#062;' ), '<foo>', 'numeric HTML entities are decoded' );
    $hs->eof;
    is( $hs->parse( '&lt;foo&gt;' ), '<foo>', 'HTML entities are decoded' );
    $hs->eof;

    $hs->set_decode_entities(0);
    is( $hs->parse( '&#060;foo&#062;' ), '&#060;foo&#062;', 'entities decoding off works' );
    $hs->eof;

    is( $hs->parse( '&lt;foo&gt;' ), '&lt;foo&gt;', 'entities decoding off works' );
    $hs->eof;
}

TODO: {
    local $TODO = "fix CDATA handling";
    is( $hs->parse( '<![INCLUDE CDATA [ >>>>>>>>>>>> ]]>bar' ), 'bar', 'character data gets stripped' );
    $hs->eof;
}

