package File::ChangeNotify::Watcher::Inotify;

use strict;
use warnings;

use File::Find qw( finddepth );
use Linux::Inotify2;

use Moose;

extends 'File::ChangeNotify::Watcher';

has is_blocking =>
    ( is       => 'ro',
      isa      => 'Bool',
      default  => 1,
    );

has _inotify =>
    ( is       => 'ro',
      isa      => 'Linux::Inotify2',
      default  => sub { Linux::Inotify2->new() },
      init_arg => undef,
    );

has _mask =>
    ( is         => 'ro',
      isa        => 'Int',
      lazy_build => 1,
    );

sub sees_all_events { 1 }

sub BUILD
{
    my $self = shift;

    $self->_inotify()->blocking( $self->is_blocking() );

    # If this is done via a lazy_build then the call to
    # ->_watch_directory ends up causing endless recursion when it
    # calls ->_inotify itself.
    $self->_watch_directory($_) for @{ $self->directories() };

    return $self;
}

sub _wait_for_events
{
    my $self = shift;

    $self->_inotify()->blocking(1);

    while (1)
    {
        my @events = $self->_interesting_events();
        return @events if @events;
    }
}

override new_events => sub
{
    my $self = shift;

    $self->_inotify()->blocking(0);

    super();
};

sub _interesting_events
{
    my $self = shift;

    my $regex = $self->regex();

    my @interesting;

    # This is a blocking read, so it will not return until
    # something happens. The restarter will end up calling ->watch
    # again after handling the changes.
    for my $event ( $self->_inotify()->read() )
    {
        if ( $event->IN_CREATE() && $event->IN_ISDIR() )
        {
            $self->_watch_directory( $event->fullname() );
            push @interesting, $event;
            push @interesting, $self->_fake_events_for_new_dir( $event->fullname() );
        }
        elsif ( $event->IN_DELETE_SELF()
                # We just want to check the _file_ name
                || $event->name() =~ /$regex/ )
        {
            $self->_remove_directory( $event->fullname() )
                if $event->IN_DELETE_SELF();

            push @interesting, $event;
        }
    }

    return
        map { $_->can('path') ? $_ : $self->_convert_event($_) } @interesting;
}

sub _build__mask
{
    my $self = shift;

    my $mask = IN_MODIFY | IN_CREATE | IN_DELETE | IN_DELETE_SELF | IN_MOVE_SELF;
    $mask |= IN_DONT_FOLLOW unless $self->follow_symlinks();

    return $mask;
}

sub _watch_directory
{
    my $self = shift;
    my $dir  = shift;

    # A directory could be created & then deleted before we get a
    # chance to act on it.
    return unless -d $dir;

    finddepth
        ( { wanted      => sub { $self->_add_watch_if_dir($File::Find::name) },
            follow_fast => ( $self->follow_symlinks() ? 1 : 0 ),
            no_chdir    => 1
          },
          $dir
        );
}

sub _add_watch_if_dir
{
    my $self = shift;
    my $path = shift;

    return if -l $path && ! $self->follow_symlinks();

    return unless -d $path;

    $self->_inotify()->watch( $path, $self->_mask() );
}

sub _fake_events_for_new_dir
{
    my $self = shift;
    my $dir  = shift;

    return unless -d $dir;

    my @events;
    finddepth
        ( { wanted      => sub { my $path = $File::Find::name;

                                 return if $path eq $dir;

                                 push @events,
                                     $self->event_class()->new
                                         ( path       => $path,
                                           event_type => 'create',
                                         );
                               },
            follow_fast => ( $self->follow_symlinks() ? 1 : 0 ),
            no_chdir    => 1
          },
          $dir
        );

    return @events;
}

sub _convert_event
{
    my $self  = shift;
    my $event = shift;

    return
        $self->event_class()->new
            ( path       => $event->fullname(),
              event_type =>
                  (   $event->IN_CREATE()
                    ? 'create'
                    : $event->IN_MODIFY()
                    ? 'modify'
                    : $event->IN_DELETE()
                    ? 'delete'
                    : 'unknown'
                  ),
                );
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;

__END__

=head1 NAME

File::ChangeNotify::Watcher - Watch for changed application files

=head1 SYNOPSIS

    my $watcher = File::ChangeNotify::Watcher->new(
        directory => '/path/to/MyApp',
        regex     => '\.yml$|\.yaml$|\.conf|\.pm$',
        interval  => 3,
    );

    while (1) {
        my @changed_files = $watcher->watch();
    }

=head1 DESCRIPTION

This class monitors a directory of files for changes made to any file
matching a regular expression. It correctly handles new files added to the
application as well as files that are deleted.

=head1 METHODS

=head2 new ( directory => $path [, regex => $regex, delay => $delay ] )

Creates a new Watcher object.

=head2 find_changed_files

Returns a list of files that have been added, deleted, or changed
since the last time watch was called. Each element returned is a hash
reference with two keys. The C<file> key contains the filename, and
the C<status> key contains one of "modified", "added", or "deleted".

=head1 AUTHOR

Dave Rolsky, E<gt>autarch@urth.orgE<lt>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Dave Rolsky, All Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
