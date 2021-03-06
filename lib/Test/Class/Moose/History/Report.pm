package Test::Class::Moose::History::Report;
use Moose;
use namespace::autoclean;
use DateTime;
use Carp;

with qw(Test::Class::Moose::History::Role::Database);

sub BUILD {
    my $self   = shift;
    my $tables = $self->_dbh->selectall_arrayref("SELECT * FROM sqlite_master WHERE type='table';");
    unless (@$tables) {
        my $database = $self->database_file;
        croak(
            "Database '$database' appears to be empty. Have you run Test::Class::Moose::History->save yet?"
        );
    }
}

sub top_failures {
    my ( $self, $arg_for ) = @_;
    $arg_for ||= {};
    my $limit       = $arg_for->{limit}       // 10;
    my $days_ago    = $arg_for->{days_ago}    // 365;
    my $show_branch = $arg_for->{show_branch} // 0;
    my $branch      = '';
    my @args;

    if ( $arg_for->{branch} ) {
        $branch = "AND source_branch = ?";
        push @args => $arg_for->{branch};
    }
    if ($show_branch) {
        $branch = 'source_ranch,';
    }
    push @args =>
      ( DateTime->now->subtract( days => $days_ago )->ymd, $limit );
    my $sql = <<"SQL";
  SELECT tc.name, tm.name, $branch min(start_date), max(start_date), count(*)
    FROM test t 
    JOIN test_method tm on t.test_method_id = tm.test_method_id 
    JOIN test_class  tc on tc.test_class_id = tm.test_class_id
    JOIN test_run    tr on tr.test_run_id   = t.test_run_id
   WHERE t.passed   = 0
         $branch
GROUP BY tm.name
  HAVING max(start_date) >= ?
ORDER BY count(*) desc
   LIMIT ?;
SQL
    my $results = $self->_dbh->selectall_arrayref( $sql, {}, @args );
    my @headers
      = $show_branch
      ? (qw/class test branch first last errs/)
      : (qw/class test first last errs/);
    my @rows = $arg_for->{headers} ? ( \@headers, @$results ) : @$results;
    return \@rows;
}

sub last_failures {
    my ($self) = @_;

    my $test_run_id = $self->_dbh->selectcol_arrayref(<<'SQL')->[0];
    SELECT max(tr.test_run_id)
      FROM test_run tr
      JOIN test     t ON tr.test_run_id = t.test_run_id
     WHERE t.passed = 0
SQL
    unless ( defined $test_run_id ) {
        return [];
    }
    my $sql = <<"SQL";
  SELECT tc.name, tm.name
    FROM test t 
    JOIN test_method tm on t.test_method_id = tm.test_method_id 
    JOIN test_class  tc on tc.test_class_id = tm.test_class_id
    JOIN test_run    tr on tr.test_run_id   = t.test_run_id
   WHERE t.passed   = 0
     AND tr.test_run_id = ?
SQL
    return $self->_dbh->selectall_arrayref( $sql, {}, $test_run_id );
}

sub last_test_status {
    my $self = shift;

    # gets the last runtime information for each test in our database
    return $self->_dbh->selectall_arrayref(<<'SQL');
    SELECT tc.name, tm.name, t.runtime, t.passed
      FROM test t
      JOIN test_method tm ON t.test_method_id = tm.test_method_id
      JOIN test_class  tc ON tm.test_class_id = tc.test_class_id
      JOIN test_run    tr ON t.test_run_id    = tr.test_run_id
  GROUP BY tm.name, tc.name
  ORDER BY tr.start_date DESC
SQL
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Test::Class::Moose::History::Report - Get report history

=head1 SYNOPSIS

    my $report = Test::Class::Moose::History::Report->new;
    my $last_failures = $report->last_failures;

See C<Test::Class::Moose::History> to understand how to add data to the
report. The constructor will C<croak> if no report tables are found.

=head1 METHODS

=head2 C<top_failures>

    use Text::Table::Tiny 'generate_table';
    my $failures = Test::Class::Moose::History->new->report->top_failures({
        limit    => $limit,      # integer, defaults to 10
        branch   => $branch,     # optional
        days_ago => $integer,    # optional, default 365
        headers  => $boolean,    # add header row
    });
    say generate_table( rows => $failures, header_row => 1 );

Returns an array reference of tests which fail the most.

=head2 C<last_failures>

    my $last_failures = $report->last_failures;
    foreach my $failure (@$last_failures) {
        my ( $test_class_name, $test_method_name ) = @$failure;
        ...
    }

Returns an array reference of all test classes and methods from the last test
run which failed.

=head2 C<last_test_status>

    my $last_test_status = $report->last_test_status;
    foreach my $test (@$last_test_status) {
        my ( $file, $method, $runtime, $passed ) = @$test;
        ...
    }

Returns an array reference of test status of every test method in the
database.
