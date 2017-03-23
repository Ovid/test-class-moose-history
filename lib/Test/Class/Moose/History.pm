package Test::Class::Moose::History;

use 5.14.0;
use Moose;
use DBI;
use Carp 'croak';
use DateTime;
use Sys::Hostname 'hostname';
use namespace::autoclean;
use Test::Class::Moose::History::Report;

with qw(Test::Class::Moose::History::Role::Database);

our $VERSION = '0.01';

has 'runner' => (
    is  => 'ro',
    isa => 'Test::Class::Moose::Runner',
);

has 'start' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_start',
);

sub _build_start {
    my $self   = shift;
    my $runner = $self->runner
      or croak("->start requires that you pass 'runner' to the constructor");
    return ''
      . DateTime->from_epoch(
        epoch => $runner->test_report->{_start_benchmark}[0] );
}

has 'end' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_end',
);

sub _build_end {
    my $self   = shift;
    my $runner = $self->runner
      or croak("->end requires that you pass 'runner' to the constructor");
    return ''
      . DateTime->from_epoch(
        epoch => $runner->test_report->{_end_benchmark}[0] );
}

has 'report' => (
    is      => 'ro',
    isa     => 'Test::Class::Moose::History::Report',
    lazy    => 1,
    builder => '_build_report',
);

sub _build_report {
    my $self = shift;
    return Test::Class::Moose::History::Report->new(
        { _dbh => $self->_dbh } );
}

has [qw/branch commit/] => (
    is      => 'ro',
    isa     => 'Str',
    default => '[unknown]',
);

sub save {
    my $self   = shift;
    my $runner = $self->runner
      or croak("->save requires that you pass 'runner' to the constructor");

    my @results;
    foreach my $class ( $runner->test_report->all_test_classes ) {
        my $test = $class->name;
        foreach my $instance ( $class->all_test_instances ) {
            for my $method ( $instance->all_test_methods ) {
                my $method_name = $method->name;
                push @results => {
                    test   => $test,
                    method => $method_name,
                    passed => $method->passed,
                    time   => $method->time->user,
                };
            }
        }
    }
    $self->_save_results( \@results );
}

sub _save_results {
    my ( $self, $results ) = @_;
    $self->_create_tables_if_not_exists;
    my $test_run_id = $self->_add_test_run;
    $self->_add_test_classes_and_methods($results);
    $self->_add_test_results( $test_run_id, $results );
    $self->_dbh->commit;
}

sub _add_test_run {
    my ($self) = @_;
    my $host   = hostname();
    my $user   = getpwuid($<);

    my $sql = <<'SQL';
    INSERT INTO test_run (start_date, end_date, hostname, user, source_branch, source_commit)
    VALUES               (         ?,        ?,        ?,    ?,             ?,             ?)
SQL

    $self->_dbh->do(
        $sql,
        {},
        $self->start, $self->end, $host, $user, $self->branch, $self->commit
    );
    return $self->_dbh->last_insert_id( '', '', '', '' )
      ; # http://search.cpan.org/~ishigaki/DBD-SQLite-1.50/lib/DBD/SQLite.pm#$dbh->sqlite_last_insert_rowid()
}

sub _add_test_classes_and_methods {
    my ( $self, $results ) = @_;

    my $dbh = $self->_dbh;
    foreach my $result (@$results) {
        my $name = $result->{test};
        my $method   = $result->{method};
        my ( $test_class_id, $test_method_id );
        my $id = $dbh->selectrow_arrayref(
            "SELECT test_class_id FROM test_class WHERE name = ?", {},
            $name
        );
        if ( $id && $id->[0] ) {
            $test_class_id = $id->[0];
        }
        else {
            $dbh->do(
                "INSERT INTO test_class (name) VALUES ( ? )",
                {}, $name,
            );
            $test_class_id = $dbh->last_insert_id( '', '', '', '' );
        }
        $result->{test_class_id} = $test_class_id;
        $id = $dbh->selectrow_arrayref(
            "SELECT test_method_id FROM test_method WHERE name = ? AND test_class_id = ?",
            {},
            $method, $test_class_id
        );
        if ( $id && $id->[0] ) {
            $test_method_id = $id->[0];
        }
        else {
            $dbh->do(
                "INSERT INTO test_method (name,test_class_id) VALUES ( ?, ? )",
                {}, $method, $test_class_id,
            );
            $test_method_id = $dbh->last_insert_id( '', '', '', '' );
        }
        $result->{test_method_id} = $test_method_id;
    }
}

sub _add_test_results {
    my ( $self, $test_run_id, $results ) = @_;
    my $dbh = $self->_dbh;

    foreach my $result (@$results) {
        my $sql = <<'SQL';
INSERT INTO test (test_run_id, test_method_id, passed, runtime)
VALUES           (          ?,            ?,      ?,         ?)
SQL
        $dbh->do(
            $sql,
            {},
            $test_run_id, $result->{test_method_id}, $result->{passed},
            $result->{time}
        );
    }
}

sub _create_tables_if_not_exists {
    my $self = shift;
    my $dbh  = $self->_dbh;

    $dbh->do(<<'SQL');
    CREATE TABLE IF NOT EXISTS test_run (
      test_run_id   INTEGER PRIMARY KEY AUTOINCREMENT,
      start_date    DATETIME NOT NULL,
      end_date      DATETIME NOT NULL,
      hostname      TEXT NOT NULL,
      user          TEXT NOT NULL,
      source_branch TEXT NOT NULL,
      source_commit TEXT NOT NULL
    );
SQL
    $dbh->do(<<'SQL');
    CREATE TABLE IF NOT EXISTS test_class (
      test_class_id INTEGER PRIMARY KEY AUTOINCREMENT,
      name          TEXT NOT NULL
    );
SQL

	# XXX Warning: don't try to create a lookup table between classes and
	# methods. It *looks* like one class can have many methods and many methods
	# could be in several classes, but in reality, the names might be the
	# same, but that does not mean identity.
    $dbh->do(<<'SQL');
    CREATE TABLE IF NOT EXISTS test_method (
      test_method_id INTEGER PRIMARY KEY AUTOINCREMENT,
      test_class_id  INTEGER NOT NULL,
      name           TEXT NOT NULL,
      FOREIGN KEY (test_class_id) REFERENCES test_class(test_class_id)
    );
SQL
    $dbh->do(<<'SQL');
    CREATE TABLE IF NOT EXISTS test (
      test_id        INTEGER PRIMARY KEY AUTOINCREMENT,
      test_run_id    INTEGER NOT NULL,
      test_method_id INTEGER NOT NULL,
      passed         BOOLEAN NOT NULL,
      runtime        REAL NOT NULL,
      FOREIGN KEY (test_run_id)    REFERENCES test_run(test_run_id),
      FOREIGN KEY (test_method_id) REFERENCES test_method(test_method_id)
  );
SQL
}

sub DEMOLISH {
    my ($self) = @_;
    $self->_dbh->disconnect if $self->database_used;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Test::Class::Moose::History - track test history over time

=head1 SYNOPSIS

    my $runner = Test::Class::Moose::Runner->new( %opts );

    # get current branch and latest commit id
    # example assumes `git`, but you can use any info you need here
    chomp( my $branch = `git rev-parse --abbrev-ref HEAD` );
    chomp( my $commit = `git rev-parse HEAD` );

    $runner->runtests;

    my $history = Test::Class::Moose::History->new(
        runner => $runner,
        branch => $branch,
        commit => $commit,
    );
    $history->save;

Later:

    # print report of top failures for last 30 days
    use Text::Table::Tiny 'generate_table';
    my $report   = Test::Class::Moose::History->new->report;
    my $failures = $report->top_failures(
        {   days_ago => 30,    # optional
            headers  => 1,
        }
    );
    say generate_table( rows => $failures, header_row => 1 );

See C<Test::Class::Moose::History::Report> for report options.

=head1 DESCRIPTION

This is a bit of a hack. You've been warned. It's used to store and retrieve
test state history for C<Test::Class::Moose> test suites.

The data is stored in an SQLite database. By default, this is located at
C<.perl_tcm_history.db>, but you may pass C<database_file> to the constructor
to override this.

In some environments, such as Jenkins, this can be tricky, so setting the
C<PERL_TCM_HISTORY_DB> environment variable will have the same effect (but
will not override any argument passed to the constructor).

=head1 CONSTRUCTOR ARGS

All arguments are optional.

=head2 C<database_file>

The data is stored in an SQLite database. By default, this is located at
C<.perl_tcm_history.db>, but you may pass C<database_file> to the constructor
to override this.

In some environments, such as Jenkins, this can be tricky, so setting the
C<PERL_TCM_HISTORY_DB> environment variable will have the same effect (but
will not override any argument passed to the constructor).

=head2 C<runner>

Should be a C<Test::Class::Moose::Runner> instance.

=head2 C<start>

This is the start time of the test suite. We consult the C<runner> to
determine this, but you can pass a string to override this. This will be saved
in the database as the start date. It should be a date format that SQLite can
recognize. A stringified C<DateTime> value works well.

=head2 C<end>

Same as C<start>, but representing the end time of the test suite.

=head2 C<branch>

The name of the branch the tests were run on. By default, this value is
C<[unknown]>.

=head2 C<commit>

The commit of the branch the tests were run on. By default, this value is
C<[unknown]>.

=head1 AUTHOR

Curtis "Ovid" Poe, C<< <ovid at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-test-class-moose-history at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Test-Class-Moose-History>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Test::Class::Moose::History

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test-Class-Moose-History>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Test-Class-Moose-History>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Test-Class-Moose-History>

=item * Search CPAN

L<http://search.cpan.org/dist/Test-Class-Moose-History/>

=back


=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2017 Curtis "Ovid" Poe.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Test::Class::Moose::History
