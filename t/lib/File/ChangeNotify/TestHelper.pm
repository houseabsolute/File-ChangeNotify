package
    File::ChangeNotify::TestHelper;

use strict;
use warnings;

use File::ChangeNotify;
use File::Temp qw( tempdir );
use Test::More;

use base 'Exporter';

our @EXPORT = qw( run_tests );

our $_DESC;

sub run_tests
{
    my @classes = File::ChangeNotify->usable_classes();

    plan 'no_plan'; # $count * @classes * 2

    for my $class (@classes)
    {
        local $_DESC = "[with $class in blocking mode]";
        _basic_tests( $class, \&_blocking );

        local $_DESC = "[with $class in nonblocking mode]";
        _basic_tests( $class, \&_nonblocking );
    }
}

sub _blocking
{
    my $watcher = shift;

    my $receiver = ReceiveEvents->new();

    $watcher->watch($receiver);

    return $receiver->events();
}

sub _nonblocking
{
    my $watcher = shift;

    return $watcher->new_events();
}

sub _basic_tests
{
    my $class      = shift;
    my $events_sub = shift;

    my $dir = tempdir( UNLINK => 1 );

    my $watcher = $class->new( directories     => $dir,
                               follow_symlinks => 0,
                             );

    my $path = "$dir/whatever";
    add_file($path);

    _check_events
        ( 1,
          [ $events_sub->($watcher) ],
          [ { path => $path,
              type => 'create',
            },
          ],
          "added one file ($path)",
        );

    modify_file($path);

    _check_events
        ( 1,
          [ $events_sub->($watcher) ],
          [ { path => $path,
              type => 'modify',
            },
          ],
          "modified one file ($path)",
        );

    delete_file($path);

    _check_events
        ( 1,
          [ $events_sub->($watcher) ],
          [ { path => $path,
              type => 'delete',
            },
          ],
          "deleted one file ($path)",
        );
}

sub _check_events
{
    my $count         = shift;
    my $got_events    = shift;
    my $expect_events = shift;
    my $desc          = shift;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $noun = $count == 1 ? 'event' : 'events';

    is( scalar @{ $got_events }, 1,
        "got $count $noun $_DESC" );

    return unless $count;

    _is_events( $got_events,
                $expect_events,
                $desc,
              );
}

sub _is_events
{
    my $got      = shift;
    my $expected = shift;
    my $desc     = shift;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    is_deeply( [ map { { path => $_->path(), type => $_->event_type() } } @{ $got } ],
               $expected,
               "$desc $_DESC"
             );
}

sub add_file
{
    my $path  = shift;

    open my $fh, '>', $path
        or die "Cannot write to $path: $!";
    close $fh
        or die "Cannot write to $path: $!";
}

sub modify_file
{
    my $path = shift;

    die "No such file $path!\n" unless -f $path;

    open my $fh, '>>', $path
        or die "Cannot write to $path: $!";
    print {$fh} "1\n"
        or die "Cannot write to $path: $!";
    close $fh
        or die "Cannot write to $path: $!";
}

sub delete_file
{
    my $path = shift;

    die "No such file $path!\n" unless -f $path;

    unlink $path
        or die "Cannot unlink $path: $!";
}

package
    ReceiveEvents;

sub new { bless [] }

sub handle_events
{
    my $self = shift;

    push @{ $self }, @_;
}

sub events { @{ $_[0] } }

1;
