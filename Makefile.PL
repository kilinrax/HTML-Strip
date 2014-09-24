
use 5.006;
use ExtUtils::MakeMaker;
my $EUMM_VERSION = eval $ExtUtils::MakeMaker::VERSION;

WriteMakefile(
    'NAME'              => 'HTML::Strip',
    'VERSION_FROM'      => 'Strip.pm',
    'PREREQ_PM'         => {
        # core modules
        'warnings'      => 0,
        'strict'        => 0,
        'Carp'          => 0,
        'Exporter'      => 0,
        'DynaLoader'    => 0,

        # build requires
        'Test::More'    => 0,
    },
  ( $] >= 5.005 ? (
    ABSTRACT_FROM       => 'Strip.pm',
    AUTHOR              => 'Alex Bowley <kilinrax@cpan.org>'
  ) : () ),
  ( $EUMM_VERSION >= 6.46 ? (
    LICENSE             => 'perl',
    META_MERGE => {
        recommended => {
            'HTML::Entities' => 0,
        },
    },
  ) : () ),
    'LIBS'              => [''], # e.g., '-lm'
    'DEFINE'            => '', # e.g., '-DHAVE_SOMETHING'
    'INC'               => '', # e.g., '-I/usr/include/other'
    'OBJECT'            => '$(O_FILES)', # link all the C files too
);
