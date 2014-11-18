use Test::More tests => 2;

BEGIN { use_ok 'HTML::Strip' }

# test for RT#19036
{
    my $hs = HTML::Strip->new();
    is( $hs->parse( '<tr><td>01 May 2006</td><td>0</td><td>10</td></tr>' ), '01 May 2006 0 10', "whitespace single character bug" );
    $hs->eof;
}
