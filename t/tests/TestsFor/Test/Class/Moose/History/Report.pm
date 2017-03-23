package TestsFor::Test::Class::Moose::History::Report;

use Test::Class::Moose extends => 'TestsFor::Base';
use namespace::autoclean;

sub test_empty_database {
    my $test  = shift;
    my $class = $test->class_name;
    can_ok $class, qw/last_test_status last_failures top_failures/;
    throws_ok { $class->new( database_file => ':memory:' ) }
    qr/\QDatabase ':memory:' appears to be empty. Have you run Test::Class::Moose::History->save yet?/,
      'Trying to report from an empty database should fail';
}

__PACKAGE__->meta->make_immutable;

1;
