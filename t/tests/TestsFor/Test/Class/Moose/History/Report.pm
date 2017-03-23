package TestsFor::Test::Class::Moose::History::Report;

use Test::Class::Moose extends => 'TestsFor::Base';
use namespace::autoclean;

sub test_basics {
    my $test  = shift;
    my $class = $test->class_name;
    can_ok $class, qw/last_test_status last_failures top_failures/;
}

__PACKAGE__->meta->make_immutable;

1;
