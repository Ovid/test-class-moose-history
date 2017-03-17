#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Test::Class::Moose::History' ) || print "Bail out!\n";
}

diag( "Testing Test::Class::Moose::History $Test::Class::Moose::History::VERSION, Perl $], $^X" );
