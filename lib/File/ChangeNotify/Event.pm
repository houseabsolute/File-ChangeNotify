package File::ChangeNotify::Event;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.26';

use Types::Standard qw( Str );
use Type::Utils qw( enum );

use Moo;

has path => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has type => (
    is       => 'ro',
    isa      => enum( [qw( create modify delete unknown )] ),
    required => 1,
);

__PACKAGE__->meta()->make_immutable();

1;

# ABSTRACT: Class for file change events

__END__

=head1 SYNOPSIS

    my $watcher = File::ChangeNotify->instantiate_watcher(
        directories => [ '/my/path', '/my/other' ],
        filter      => qr/\.(?:pm|conf|yml)$/,
        exclude => [ 't', 'root', qr(/(?!\.)[^/]+$) ],
    );

    for my $event ( $watcher->new_events() ) {
        print $event->path(), ' - ', $event->type(), "\n";
    }

=head1 DESCRIPTION

This class provides information about a change to a specific file or
directory.

=head1 METHODS

=head2 File::ChangeNotify::Event->new(...)

This method creates a new event. It accepts the following arguments:

=over 4

=item * path => $path

The full path to the file or directory that changed.

=item * type => $type

The type of event. This must be one of "create", "modify", "delete", or
"unknown".

=back

=head2 $event->path()

Returns the path of the changed file or directory.

=head2 $event->type()

Returns the type of event.

=cut
