package Test::Class::Moose::History::Role::Database;
use Moose::Role;

has 'database_file' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_database_file',
);

sub _build_database_file {
    return $ENV{PERL_TCM_HISTORY_DB} // '.perl_tcm_history.db';
}

has '_dbh' => (
    is        => 'ro',
    isa       => 'DBI::db',
    predicate => 'database_used',
    lazy      => 1,
    builder   => '_build_dbh',
);

sub _build_dbh {
    my $self   = shift;
    my $dbfile = $self->database_file;
    return DBI->connect(
        "dbi:SQLite:dbname=$dbfile",
        "", "",
        {   RaiseError => 1,
            AutoCommit => 0,
        }
    );
}

1;
