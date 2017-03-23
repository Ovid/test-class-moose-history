package TestsFor::Test::Class::Moose::History;

use Test::Class::Moose extends => 'TestsFor::Base';
use namespace::autoclean;

sub test_basics {
    my $test    = shift;
    my $runner  = $test->fake_runner;
    my $history = Test::Class::Moose::History->new(
        runner        => $test->fake_runner,
        branch        => 'some_branch',
        commit        => 'abcd1234',
        database_file => ':memory:',
    );
    $history->save;
    my $report = $history->report;

    my %expected = (
        last_test_status => [
            [   'TestsFor::Test::Class::Moose::History', 'test_basics', '0', 1
            ],
            [   'TestsFor::Test::Class::Moose::History::Report',
                'test_basics', '0', 1
            ],
            [   'TestsFor::Test::Class::Moose::History',
                'test_forced_failure', '0', 0
            ]
        ],
        last_failures => [
            [   'TestsFor::Test::Class::Moose::History',
                'test_forced_failure'
            ]
        ],
        top_failures => [
            [   'TestsFor::Test::Class::Moose::History',
                'test_forced_failure', '2017-03-23T14:43:48',
                '2017-03-23T14:43:48', 1
            ]
        ],
    );
    foreach my $method ( sort keys %expected ) {
        my $result = $report->$method;
        eq_or_diff $result, $expected{$method},
          "Report results for $method should be correct";
    }
}

sub fake_runner {
    my $test = shift;
    no strict;
    my $runner = eval <<'END';
$runner = bless( {
  '_executor' => bless( {
    'test_configuration' => bless( {
      'builder' => bless( {
        'Exported_To' => 'Test::Class::Moose::Role::Executor',
        'Orig_Handles' => [
          \*{'Test2::Formatter::TAP::$out'},
          \*{'Test2::Formatter::TAP::$err'},
          do{my $o}
        ],
        'Original_Pid' => 61749,
        'Stack' => bless( [
          bless( {
            '_formatter' => bless( {
              'handles' => [
                do{my $o},
                do{my $o},
                do{my $o}
              ],
              'no_header' => 0,
              'no_numbers' => ''
            }, 'Test::Builder::Formatter' ),
            '_meta' => {
              'Test::Builder' => {
                'Done_Testing' => [
                  'Moose::Meta::Method::Delegation',
                  '.../Moose/Meta/Method/Delegation.pm',
                  110,
                  'Test::Class::Moose::Executor::Sequential::runtests'
                ],
                'Ending' => 0,
                'Name' => 't/tcm.t',
                'Skip_All' => 0,
                'Test_Results' => [
                  {
                    'actual_ok' => 1,
                    'name' => 'TestsFor::Base',
                    'ok' => 1,
                    'reason' => 'Skipping \'TestsFor::Base\': no test methods found',
                    'type' => 'skip'
                  },
                  {
                    'actual_ok' => 0,
                    'name' => 'TestsFor::Test::Class::Moose::History',
                    'ok' => 0,
                    'reason' => '',
                    'type' => ''
                  },
                  {
                    'actual_ok' => 1,
                    'name' => 'TestsFor::Test::Class::Moose::History::Report',
                    'ok' => 1,
                    'reason' => '',
                    'type' => ''
                  }
                ]
              }
            },
            '_passing' => 0,
            '_plan' => 3,
            '_pre_filters' => [
              {
                'code' => sub { "DUMMY" },
                'inherit' => 1
              }
            ],
            'count' => 3,
            'ended' => [
              'Moose::Meta::Method::Delegation',
              '.../Moose/Meta/Method/Delegation.pm',
              110,
              'Test::Class::Moose::Executor::Sequential::runtests'
            ],
            'failed' => 1,
            'hid' => '61749-0-1',
            'no_ending' => 0,
            'pid' => 61749,
            'tid' => 0
          }, 'Test2::Hub' )
        ], 'Test2::API::Stack' )
      }, 'Test::Builder' ),
      'randomize' => 0,
      'randomize_classes' => 0,
      'set_process_name' => 0,
      'show_timing' => undef,
      'statistics' => undef
    }, 'Test::Class::Moose::Config' ),
    'test_report' => bless( {
      '_end_benchmark' => bless( [
        '1490280228.94836',
        '0.5',
        '0.03',
        '0',
        '0',
        0
      ], 'Benchmark' ),
      '_start_benchmark' => bless( [
        '1490280228.93922',
        '0.49',
        '0.03',
        '0',
        '0',
        0
      ], 'Benchmark' ),
      'is_parallel' => 0,
      'num_test_methods' => 3,
      'num_tests_run' => 3,
      'test_classes' => [
        bless( {
          '_start_benchmark' => bless( [
            '1490280228.9404',
            '0.49',
            '0.03',
            '0',
            '0',
            0
          ], 'Benchmark' ),
          'name' => 'TestsFor::Base',
          'notes' => {},
          'passed' => 0,
          'test_instances' => [
            bless( {
              'name' => 'TestsFor::Base',
              'notes' => {},
              'passed' => 1,
              'skipped' => 'Skipping \'TestsFor::Base\': no test methods found',
              'test_methods' => []
            }, 'Test::Class::Moose::Report::Instance' )
          ]
        }, 'Test::Class::Moose::Report::Class' ),
        bless( {
          '_end_benchmark' => bless( [
            '1490280228.9458',
            '0.5',
            '0.03',
            '0',
            '0',
            0
          ], 'Benchmark' ),
          '_start_benchmark' => bless( [
            '1490280228.94257',
            '0.49',
            '0.03',
            '0',
            '0',
            0
          ], 'Benchmark' ),
          'name' => 'TestsFor::Test::Class::Moose::History',
          'notes' => {},
          'passed' => 0,
          'test_instances' => [
            bless( {
              '_end_benchmark' => bless( [
                '1490280228.94578',
                '0.5',
                '0.03',
                '0',
                '0',
                0
              ], 'Benchmark' ),
              '_start_benchmark' => bless( [
                '1490280228.94279',
                '0.49',
                '0.03',
                '0',
                '0',
                0
              ], 'Benchmark' ),
              'name' => 'TestsFor::Test::Class::Moose::History',
              'notes' => {},
              'passed' => 0,
              'test_methods' => [
                bless( {
                  '_end_benchmark' => bless( [
                    '1490280228.94373',
                    '0.49',
                    '0.03',
                    '0',
                    '0',
                    0
                  ], 'Benchmark' ),
                  '_start_benchmark' => bless( [
                    '1490280228.94354',
                    '0.49',
                    '0.03',
                    '0',
                    '0',
                    0
                  ], 'Benchmark' ),
                  'instance' => {},
                  'name' => 'test_basics',
                  'notes' => {},
                  'num_tests_run' => 1,
                  'passed' => 1,
                  'test_setup_method' => bless( {
                    '_end_benchmark' => bless( [
                      '1490280228.94323',
                      '0.49',
                      '0.03',
                      '0',
                      '0',
                      0
                    ], 'Benchmark' ),
                    '_start_benchmark' => bless( [
                      '1490280228.94315',
                      '0.49',
                      '0.03',
                      '0',
                      '0',
                      0
                    ], 'Benchmark' ),
                    'instance' => {},
                    'name' => 'test_setup',
                    'notes' => {},
                    'num_tests_run' => 0,
                    'passed' => 0
                  }, 'Test::Class::Moose::Report::Method' ),
                  'test_teardown_method' => bless( {
                    '_end_benchmark' => bless( [
                      '1490280228.94417',
                      '0.49',
                      '0.03',
                      '0',
                      '0',
                      0
                    ], 'Benchmark' ),
                    '_start_benchmark' => bless( [
                      '1490280228.94409',
                      '0.49',
                      '0.03',
                      '0',
                      '0',
                      0
                    ], 'Benchmark' ),
                    'instance' => {},
                    'name' => 'test_teardown',
                    'notes' => {},
                    'num_tests_run' => 0,
                    'passed' => 0
                  }, 'Test::Class::Moose::Report::Method' ),
                  'tests_planned' => 1,
                  'time' => bless( {
                    '_timediff' => bless( [
                      '0.000190973281860352',
                      '0',
                      '0',
                      0,
                      0,
                      0
                    ], 'Benchmark' ),
                    'user' => 0
                  }, 'Test::Class::Moose::Report::Time' )
                }, 'Test::Class::Moose::Report::Method' ),
                bless( {
                  '_end_benchmark' => bless( [
                    '1490280228.94506',
                    '0.5',
                    '0.03',
                    '0',
                    '0',
                    0
                  ], 'Benchmark' ),
                  '_start_benchmark' => bless( [
                    '1490280228.94461',
                    '0.5',
                    '0.03',
                    '0',
                    '0',
                    0
                  ], 'Benchmark' ),
                  'instance' => {},
                  'name' => 'test_forced_failure',
                  'notes' => {},
                  'num_tests_run' => 1,
                  'passed' => 0,
                  'test_setup_method' => bless( {
                    '_end_benchmark' => bless( [
                      '1490280228.94431',
                      '0.5',
                      '0.03',
                      '0',
                      '0',
                      0
                    ], 'Benchmark' ),
                    '_start_benchmark' => bless( [
                      '1490280228.94424',
                      '0.5',
                      '0.03',
                      '0',
                      '0',
                      0
                    ], 'Benchmark' ),
                    'instance' => {},
                    'name' => 'test_setup',
                    'notes' => {},
                    'num_tests_run' => 0,
                    'passed' => 0
                  }, 'Test::Class::Moose::Report::Method' ),
                  'test_teardown_method' => bless( {
                    '_end_benchmark' => bless( [
                      '1490280228.94565',
                      '0.5',
                      '0.03',
                      '0',
                      '0',
                      0
                    ], 'Benchmark' ),
                    '_start_benchmark' => bless( [
                      '1490280228.94557',
                      '0.5',
                      '0.03',
                      '0',
                      '0',
                      0
                    ], 'Benchmark' ),
                    'instance' => {},
                    'name' => 'test_teardown',
                    'notes' => {},
                    'num_tests_run' => 0,
                    'passed' => 0
                  }, 'Test::Class::Moose::Report::Method' ),
                  'tests_planned' => 1,
                  'time' => bless( {
                    '_timediff' => bless( [
                      '0.000454187393188477',
                      '0',
                      '0',
                      0,
                      0,
                      0
                    ], 'Benchmark' ),
                    'user' => 0
                  }, 'Test::Class::Moose::Report::Time' )
                }, 'Test::Class::Moose::Report::Method' )
              ],
              'test_shutdown_method' => bless( {
                '_end_benchmark' => bless( [
                  '1490280228.94578',
                  '0.5',
                  '0.03',
                  '0',
                  '0',
                  0
                ], 'Benchmark' ),
                '_start_benchmark' => bless( [
                  '1490280228.9457',
                  '0.5',
                  '0.03',
                  '0',
                  '0',
                  0
                ], 'Benchmark' ),
                'instance' => {},
                'name' => 'test_shutdown',
                'notes' => {},
                'num_tests_run' => 0,
                'passed' => 0
              }, 'Test::Class::Moose::Report::Method' ),
              'test_startup_method' => bless( {
                '_end_benchmark' => bless( [
                  '1490280228.94294',
                  '0.49',
                  '0.03',
                  '0',
                  '0',
                  0
                ], 'Benchmark' ),
                '_start_benchmark' => bless( [
                  '1490280228.94285',
                  '0.49',
                  '0.03',
                  '0',
                  '0',
                  0
                ], 'Benchmark' ),
                'instance' => {},
                'name' => 'test_startup',
                'notes' => {},
                'num_tests_run' => 0,
                'passed' => 0
              }, 'Test::Class::Moose::Report::Method' )
            }, 'Test::Class::Moose::Report::Instance' )
          ]
        }, 'Test::Class::Moose::Report::Class' ),
        bless( {
          '_end_benchmark' => bless( [
            '1490280228.94806',
            '0.5',
            '0.03',
            '0',
            '0',
            0
          ], 'Benchmark' ),
          '_start_benchmark' => bless( [
            '1490280228.94656',
            '0.5',
            '0.03',
            '0',
            '0',
            0
          ], 'Benchmark' ),
          'name' => 'TestsFor::Test::Class::Moose::History::Report',
          'notes' => {},
          'passed' => 1,
          'test_instances' => [
            bless( {
              '_end_benchmark' => bless( [
                '1490280228.94805',
                '0.5',
                '0.03',
                '0',
                '0',
                0
              ], 'Benchmark' ),
              '_start_benchmark' => bless( [
                '1490280228.94678',
                '0.5',
                '0.03',
                '0',
                '0',
                0
              ], 'Benchmark' ),
              'name' => 'TestsFor::Test::Class::Moose::History::Report',
              'notes' => {},
              'passed' => 1,
              'test_methods' => [
                bless( {
                  '_end_benchmark' => bless( [
                    '1490280228.94757',
                    '0.5',
                    '0.03',
                    '0',
                    '0',
                    0
                  ], 'Benchmark' ),
                  '_start_benchmark' => bless( [
                    '1490280228.94738',
                    '0.5',
                    '0.03',
                    '0',
                    '0',
                    0
                  ], 'Benchmark' ),
                  'instance' => {},
                  'name' => 'test_basics',
                  'notes' => {},
                  'num_tests_run' => 1,
                  'passed' => 1,
                  'test_setup_method' => bless( {
                    '_end_benchmark' => bless( [
                      '1490280228.94714',
                      '0.5',
                      '0.03',
                      '0',
                      '0',
                      0
                    ], 'Benchmark' ),
                    '_start_benchmark' => bless( [
                      '1490280228.94706',
                      '0.5',
                      '0.03',
                      '0',
                      '0',
                      0
                    ], 'Benchmark' ),
                    'instance' => {},
                    'name' => 'test_setup',
                    'notes' => {},
                    'num_tests_run' => 0,
                    'passed' => 0
                  }, 'Test::Class::Moose::Report::Method' ),
                  'test_teardown_method' => bless( {
                    '_end_benchmark' => bless( [
                      '1490280228.94793',
                      '0.5',
                      '0.03',
                      '0',
                      '0',
                      0
                    ], 'Benchmark' ),
                    '_start_benchmark' => bless( [
                      '1490280228.94785',
                      '0.5',
                      '0.03',
                      '0',
                      '0',
                      0
                    ], 'Benchmark' ),
                    'instance' => {},
                    'name' => 'test_teardown',
                    'notes' => {},
                    'num_tests_run' => 0,
                    'passed' => 0
                  }, 'Test::Class::Moose::Report::Method' ),
                  'tests_planned' => 1,
                  'time' => bless( {
                    '_timediff' => bless( [
                      '0.000189781188964844',
                      '0',
                      '0',
                      0,
                      0,
                      0
                    ], 'Benchmark' ),
                    'user' => 0
                  }, 'Test::Class::Moose::Report::Time' )
                }, 'Test::Class::Moose::Report::Method' )
              ],
              'test_shutdown_method' => bless( {
                '_end_benchmark' => bless( [
                  '1490280228.94804',
                  '0.5',
                  '0.03',
                  '0',
                  '0',
                  0
                ], 'Benchmark' ),
                '_start_benchmark' => bless( [
                  '1490280228.94797',
                  '0.5',
                  '0.03',
                  '0',
                  '0',
                  0
                ], 'Benchmark' ),
                'instance' => {},
                'name' => 'test_shutdown',
                'notes' => {},
                'num_tests_run' => 0,
                'passed' => 0
              }, 'Test::Class::Moose::Report::Method' ),
              'test_startup_method' => bless( {
                '_end_benchmark' => bless( [
                  '1490280228.94689',
                  '0.5',
                  '0.03',
                  '0',
                  '0',
                  0
                ], 'Benchmark' ),
                '_start_benchmark' => bless( [
                  '1490280228.94681',
                  '0.5',
                  '0.03',
                  '0',
                  '0',
                  0
                ], 'Benchmark' ),
                'instance' => {},
                'name' => 'test_startup',
                'notes' => {},
                'num_tests_run' => 0,
                'passed' => 0
              }, 'Test::Class::Moose::Report::Method' )
            }, 'Test::Class::Moose::Report::Instance' )
          ]
        }, 'Test::Class::Moose::Report::Class' )
      ]
    }, 'Test::Class::Moose::Report' )
  }, 'Test::Class::Moose::Executor::Sequential' ),
  'color_output' => 1,
  'jobs' => 1,
  'test_configuration' => {}
}, 'Test::Class::Moose::Runner' );
$runner->{'_executor'}{'test_configuration'}{'builder'}{'Orig_Handles'}[2] = $runner->{'_executor'}{'test_configuration'}{'builder'}{'Orig_Handles'}[0];
$runner->{'_executor'}{'test_configuration'}{'builder'}{'Stack'}[0]{'_formatter'}{'handles'}[0] = $runner->{'_executor'}{'test_configuration'}{'builder'}{'Orig_Handles'}[0];
$runner->{'_executor'}{'test_configuration'}{'builder'}{'Stack'}[0]{'_formatter'}{'handles'}[1] = $runner->{'_executor'}{'test_configuration'}{'builder'}{'Orig_Handles'}[1];
$runner->{'_executor'}{'test_configuration'}{'builder'}{'Stack'}[0]{'_formatter'}{'handles'}[2] = $runner->{'_executor'}{'test_configuration'}{'builder'}{'Orig_Handles'}[0];
$runner->{'_executor'}{'test_report'}{'test_classes'}[1]{'test_instances'}[0]{'test_methods'}[0]{'instance'} = $runner->{'_executor'}{'test_report'}{'test_classes'}[1]{'test_instances'}[0];
$runner->{'_executor'}{'test_report'}{'test_classes'}[1]{'test_instances'}[0]{'test_methods'}[0]{'test_setup_method'}{'instance'} = $runner->{'_executor'}{'test_report'}{'test_classes'}[1]{'test_instances'}[0];
$runner->{'_executor'}{'test_report'}{'test_classes'}[1]{'test_instances'}[0]{'test_methods'}[0]{'test_teardown_method'}{'instance'} = $runner->{'_executor'}{'test_report'}{'test_classes'}[1]{'test_instances'}[0];
$runner->{'_executor'}{'test_report'}{'test_classes'}[1]{'test_instances'}[0]{'test_methods'}[1]{'instance'} = $runner->{'_executor'}{'test_report'}{'test_classes'}[1]{'test_instances'}[0];
$runner->{'_executor'}{'test_report'}{'test_classes'}[1]{'test_instances'}[0]{'test_methods'}[1]{'test_setup_method'}{'instance'} = $runner->{'_executor'}{'test_report'}{'test_classes'}[1]{'test_instances'}[0];
$runner->{'_executor'}{'test_report'}{'test_classes'}[1]{'test_instances'}[0]{'test_methods'}[1]{'test_teardown_method'}{'instance'} = $runner->{'_executor'}{'test_report'}{'test_classes'}[1]{'test_instances'}[0];
$runner->{'_executor'}{'test_report'}{'test_classes'}[1]{'test_instances'}[0]{'test_shutdown_method'}{'instance'} = $runner->{'_executor'}{'test_report'}{'test_classes'}[1]{'test_instances'}[0];
$runner->{'_executor'}{'test_report'}{'test_classes'}[1]{'test_instances'}[0]{'test_startup_method'}{'instance'} = $runner->{'_executor'}{'test_report'}{'test_classes'}[1]{'test_instances'}[0];
$runner->{'_executor'}{'test_report'}{'test_classes'}[2]{'test_instances'}[0]{'test_methods'}[0]{'instance'} = $runner->{'_executor'}{'test_report'}{'test_classes'}[2]{'test_instances'}[0];
$runner->{'_executor'}{'test_report'}{'test_classes'}[2]{'test_instances'}[0]{'test_methods'}[0]{'test_setup_method'}{'instance'} = $runner->{'_executor'}{'test_report'}{'test_classes'}[2]{'test_instances'}[0];
$runner->{'_executor'}{'test_report'}{'test_classes'}[2]{'test_instances'}[0]{'test_methods'}[0]{'test_teardown_method'}{'instance'} = $runner->{'_executor'}{'test_report'}{'test_classes'}[2]{'test_instances'}[0];
$runner->{'_executor'}{'test_report'}{'test_classes'}[2]{'test_instances'}[0]{'test_shutdown_method'}{'instance'} = $runner->{'_executor'}{'test_report'}{'test_classes'}[2]{'test_instances'}[0];
$runner->{'_executor'}{'test_report'}{'test_classes'}[2]{'test_instances'}[0]{'test_startup_method'}{'instance'} = $runner->{'_executor'}{'test_report'}{'test_classes'}[2]{'test_instances'}[0];
$runner->{'test_configuration'} = $runner->{'_executor'}{'test_configuration'};
$runner
END
    return $runner;
}

__PACKAGE__->meta->make_immutable;

1;
