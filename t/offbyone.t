use strict;

# test for RT#94713

my $INC = join ' ', map { "-I$_" } @INC;

exec("MALLOC_OPTIONS=Z perl $INC -MTest::More -MHTML::Strip -e 'is(HTML::Strip->new->parse(q[<li>abc < 0.5 km</li><li>xyz</li>]), q[abc xyz]); done_testing()'");

