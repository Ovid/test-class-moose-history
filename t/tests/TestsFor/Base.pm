package TestsFor::Base;

use Test::Class::Moose;

with 'Test::Class::Moose::Role::AutoUse';

# so that Test::Class::Moose::Role::AutoUse doesn't try to load a
# corresponding class for this class. It's a bit of a nasty hack
around 'get_class_name_to_use' => sub {
    my $orig = shift;
    my $self = shift;
    return __PACKAGE__ eq ref $self ? () : $self->$orig(@_);
};

# Any common methods would go here.

1;
