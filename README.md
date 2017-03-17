# DISCLAIMER

This is a quick 'n dirty port of production code from [Tau
Station](https://taustation.space/). It's worked very well for us there.
That's all I can say :)

# NAME

Test::Class::Moose::History - track test history over time

# SYNOPSIS

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

See `Test::Class::Moose::History::Report` for report options.

# DESCRIPTION

This is all a nasty hack. You've been warned. It's used to store and retrieve
test state history for `Test::Class::Moose` test suites.

The data is stored in an SQLite database. By default, this is located at
`.perl_tcm_history.db`, but you may pass `database_file` to the constructor
to override this.

In some environments, such as Jenkins, this can be tricky, so setting the
`PERL_TCM_HISTORY_DB` environment variable will have the same effect (but
will not override any argument passed to the constructor).

# CONSTRUCTOR ARGS

All arguments are optional.

## `database_file`

The data is stored in an SQLite database. By default, this is located at
`.perl_tcm_history.db`, but you may pass `database_file` to the constructor
to override this.

In some environments, such as Jenkins, this can be tricky, so setting the
`PERL_TCM_HISTORY_DB` environment variable will have the same effect (but
will not override any argument passed to the constructor).

## `runner`

Should be a `Test::Class::Moose::Runner` instance.

## `start`

This is the start time of the test suite. We consult the `runner` to
determine this, but you can pass a string to override this. This will be saved
in the database as the start date. It should be a date format that SQLite can
recognize. A stringified `DateTime` value works well.

## `end`

Same as `start`, but representing the end time of the test suite.

## `branch`

The name of the branch the tests were run on. By default, this value is
`[unknown]`.

## `commit`

The commit of the branch the tests were run on. By default, this value is
`[unknown]`.

# AUTHOR

Curtis "Ovid" Poe, `<ovid at cpan.org>`

# BUGS

Please report any bugs or feature requests to `bug-test-class-moose-history at rt.cpan.org`, or through
the web interface at [http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Test-Class-Moose-History](http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Test-Class-Moose-History).  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Test::Class::Moose::History

You can also look for information at:

- RT: CPAN's request tracker (report bugs here)

    [http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test-Class-Moose-History](http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test-Class-Moose-History)

- AnnoCPAN: Annotated CPAN documentation

    [http://annocpan.org/dist/Test-Class-Moose-History](http://annocpan.org/dist/Test-Class-Moose-History)

- CPAN Ratings

    [http://cpanratings.perl.org/d/Test-Class-Moose-History](http://cpanratings.perl.org/d/Test-Class-Moose-History)

- Search CPAN

    [http://search.cpan.org/dist/Test-Class-Moose-History/](http://search.cpan.org/dist/Test-Class-Moose-History/)

# ACKNOWLEDGEMENTS

# LICENSE AND COPYRIGHT

Copyright 2017 Curtis "Ovid" Poe.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

[http://www.perlfoundation.org/artistic\_license\_2\_0](http://www.perlfoundation.org/artistic_license_2_0)

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
