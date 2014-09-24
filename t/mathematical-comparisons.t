use Test::More tests => 2;

BEGIN { use_ok 'HTML::Strip' }

# test for RT#19036
{
    my $hs = HTML::Strip->new();
    is( $hs->parse( <<EOF ), "\nhello\n", "mathematical comparisons in strip tags big RT#35345" );
<script>
function shovelerMain (detectBuyBox) {
    for (var i = 0; i < Shoveler.Instances.length; i++) {
...
</script>
<h>hello</h>
EOF
    $hs->eof;
}
