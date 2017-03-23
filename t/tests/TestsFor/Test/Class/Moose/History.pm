package TestsFor::Test::Class::Moose::History;

use Test::Class::Moose extends => 'TestsFor::Base';
use namespace::autoclean;

sub test_basics {
    my $test  = shift;
    ok 1;
}

__PACKAGE__->meta->make_immutable;

1;
