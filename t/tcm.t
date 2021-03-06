#!perl

use strict;
use warnings;
use Test::Builder;
use Test::Class::Moose::Load 't/tests';
use Test::Class::Moose::Runner;
use Test::Class::Moose::History;
use Text::Table::Tiny 'generate_table';
use Getopt::Long;
GetOptions( report => \my $report ) or die "Bad options";

my $runner = Test::Class::Moose::Runner->new;
$runner->runtests;

if ($report) {

    # example assumes `git`, but you can use any info you need here
    my ( $branch, $commit );
    if ( system("git rev-parse 2>/dev/null") == 0 ) {
        chomp( $branch = `git rev-parse --abbrev-ref HEAD` );
        chomp( $commit = `git rev-parse HEAD` );
    }
    else {
        $branch = 'fake_branch';
        $commit = 'fake_commit';
    }
    my $history = Test::Class::Moose::History->new(
        runner => $runner,
        branch => $branch,
        commit => $commit,
    );
    $history->save;
    my $report = $history->report;

    my %report_methods = (
        last_test_status => [qw/Class Method Runtime Passed/],
        last_failures    => [qw/Class Method/],
        top_failures     => [qw/class test first last errs/],
    );

    my $builder = Test::Builder->new;
    foreach my $method ( sort keys %report_methods ) {
        my $results = $report->$method;
        my @rows = ( $report_methods{$method}, @$results );
        $builder->diag("\nReport for $method");
        $builder->diag( generate_table( rows => \@rows, header_row => 1 ) );
    }
}
