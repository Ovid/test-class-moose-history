use strict;
use warnings;

use 5.010000;
use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'         => 'Test::Class::Moose::History',
    'VERSION_FROM' => 'lib/Test/Class/Moose/History.pm',
    'PREREQ_PM'    => {
        "Test::Class::Moose"   => 0.55,
        "DBI"                  => 0,
        "DateTime"             => 0,
        "namespace::autoclean" => 0.28,
        "Text::Table::Tiny"    => 0.04,
    },
    'INSTALLDIRS' => 'site',
    'EXE_FILES'   => [],
    'PL_FILES'    => {},
    META_MERGE    => {
        "meta-spec" => { version => 2 },
        resources   => {
            repository => {
                type => 'git',
                url => 'https://github.com/Ovid/test-class-moose-history.git',
                web => 'https://github.com/Ovid/test-class-moose-history',
            },
        },
    },
);
