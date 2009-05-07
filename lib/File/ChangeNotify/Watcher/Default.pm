package File::ChangeNotify::Watcher::Default;

use strict;
use warnings;

use File::Find qw( finddepth );
use Time::HiRes qw( sleep );
# Trying to import this just blows up on Win32, and checking
# Time::HiRes::d_hires_stat() _also_ blows up on Win32.
BEGIN { eval { Time::HiRes->import('stat') } }

use Moose;
use MooseX::SemiAffordanceAccessor;

extends 'File::ChangeNotify::Watcher';

has _map =>
    ( is      => 'rw',
      isa     => 'HashRef',
      default => sub { {} },
    );

has wait_interval =>
    ( is      => 'ro',
      isa     => 'Num',
      default => 2,
    );


sub sees_all_events { 0 }

sub BUILD
{
    my $self = shift;

    $self->_set_map( $self->_build_map() );
}

sub _build_map
{
    my $self = shift;

    my %map;

    finddepth
        ( { wanted      => sub { my $path = $File::Find::name;
                                 $map{$path} = $self->_entry_for_map($path);
                               },
            follow_fast => ( $self->follow_symlinks() ? 1 : 0 ),
            no_chdir    => 1
          },
          @{ $self->directories() },
       );

    return \%map;
}

sub _entry_for_map
{
    my $self = shift;
    my $path = shift;

    my $is_dir = -d $path ? 1 : 0;

    unless ($is_dir)
    {
        my $regex = $self->regex();
        return unless ( File::Spec->splitpath($path) )[2] =~ /$regex/;
    }

    return { is_dir => $is_dir,
             mtime  => _mtime(*_),
             size   => ( $is_dir ? 0 : -s _ ),
           };
}

# It seems that Time::HiRes's stat does not act exactly like the
# built-in, so if I do ( stat _ )[9] it will not work (grr).
sub _mtime
{
    my @stat = stat;

    return $stat[9];
}

sub _wait_for_events
{
    my $self = shift;

    while (1)
    {
        my @events = $self->_interesting_events();
        return @events if @events;

        sleep $self->wait_interval();
    }
}

sub _interesting_events
{
    my $self = shift;

    my @interesting;

    my $old_map = $self->_map();
    my $new_map = $self->_build_map();

    for my $path ( sort keys %{ $old_map } )
    {
        if ( ! exists $new_map->{$path} )
        {
            if ( $old_map->{$path}{is_dir} )
            {
                $self->_remove_directory($path);
            }

            push @interesting,
                $self->event_class()->new( path       => $path,
                                           event_type => 'delete',
                                         );
        }
        elsif (    ! $old_map->{$path}{is_dir}
                && (    $old_map->{$path}{mtime} != $new_map->{$path}{mtime}
                     || $old_map->{$path}{size} != $new_map->{$path}{size} )
              )
        {
            push @interesting,
                $self->event_class()->new( path       => $path,
                                           event_type => 'modify',
                                         );
        }
    }

    for my $path ( sort grep { ! exists $old_map->{$_} } keys %{ $new_map } )
    {
        if ( -d $path )
        {
            push @interesting,
                $self->event_class()->new( path       => $path,
                                           event_type => 'create',
                                         ),
        }
        else
        {
            push @interesting,
                $self->event_class()->new( path       => $path,
                                           event_type => 'create',
                                         );
        }
    }

    $self->_set_map($new_map);

    return @interesting;
}

no Moose;

__PACKAGE__->meta()->make_immutable();
