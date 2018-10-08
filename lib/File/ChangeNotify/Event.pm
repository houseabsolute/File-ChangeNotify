package File::ChangeNotify::Event;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.31';

use Types::Standard qw( ArrayRef HashRef Str );
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

has attributes => (
    is        => 'ro',
    isa       => ArrayRef [HashRef],
    predicate => 'has_attributes',
);

has content => (
    is        => 'ro',
    isa       => ArrayRef,
    predicate => 'has_content',
);

__PACKAGE__->meta->make_immutable;

1;

# ABSTRACT: Class for file change events

__END__

=head1 SYNOPSIS

    my $watcher = File::ChangeNotify->instantiate_watcher(
        directories => [ '/my/path', '/my/other' ],
        filter      => qr/\.(?:pm|conf|yml)$/,
        exclude => [ 't', 'root', qr(/(?!\.)[^/]+$) ],
    );

    for my $event ( $watcher->new_events ) {
        print $event->path, ' - ', $event->type, "\n";
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

=head2 $event->path

Returns the path of the changed file or directory.

=head2 $event->type

Returns the type of event.

=head2 $event->has_attributes

This returns true for modify events which include information about a path's
attribute changes.

=head2 $event->attributes

If the event includes information about changes to a path's attributes, then
this returns a two-element arrayref. Each element is in turn a hashref which
will contain at least one of the following keys:

=over 4

=item * permissions

The permissions mask for the path.

=item * uid

The user id that owns the path.

=item * gid

The group id that owns the path.

=back

Note that only keys which changed will be included.

=head2 $event->has_content

This returns true for modify events which include information about a file's
content.

=head2 $event->content

This returns a two-element arrayref where the first element is the old content
and the second is the new content.

B<Note that this content is stored as bytes, not UTF-8. You will need to
explicitly call C<Encode::decode> on the content to make it UTF-8.> This is
done because there's no reason you couldn't use this feature with file's
containing any sort of binary data.

=cut
