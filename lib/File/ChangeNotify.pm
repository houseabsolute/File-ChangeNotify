package File::ChangeNotify;

use strict;
use warnings;

our $VERSION = '0.25';

use Carp qw( confess );
use Module::Runtime qw( use_module );

# We load this up front to make sure that the prereq modules are installed.
use File::ChangeNotify::Watcher::Default;
use Module::Pluggable::Object;

sub instantiate_watcher {
    my $class = shift;

    my @usable = $class->usable_classes();
    return $usable[0]->new(@_) if @usable;

    return File::ChangeNotify::Watcher::Default->new(@_);
}

{
    my $finder = Module::Pluggable::Object->new(
        search_path => 'File::ChangeNotify::Watcher' );
    my $loaded         = 0;
    my @usable_classes = ();

    sub usable_classes {
        my $class = shift;

        return @usable_classes if $loaded;
        @usable_classes = grep { _try_load($_) }
            sort grep { $_ ne 'File::ChangeNotify::Watcher::Default' }
            $finder->plugins();
        $loaded = 1;

        return @usable_classes;
    }
}

sub _try_load {
    my $class = shift;

    my $ok = eval { use_module($class) };
    my $e = $@;
    return $class if $ok;

    die $e
        if $e
        && $e !~ /Can\'t locate|did not return a true value/;
}

1;

# ABSTRACT: Watch for changes to files, cross-platform style

__END__

=pod

=head1 SYNOPSIS

    use File::ChangeNotify;

    my $watcher =
        File::ChangeNotify->instantiate_watcher
            ( directories => [ '/my/path', '/my/other' ],
              filter      => qr/\.(?:pm|conf|yml)$/,
            );

    if ( my @events = $watcher->new_events() ) { ... }

    # blocking
    while ( my @events = $watcher->wait_for_events() ) { ... }

=head1 DESCRIPTION

This module provides an API for creating a
L<File::ChangeNotify::Watcher> subclass that will work on your
platform.

Most of the documentation for this distro is in
L<File::ChangeNotify::Watcher>.

=head1 METHODS

This class provides the following methods:

=head2 File::ChangeNotify->instantiate_watcher(...)

This method looks at each available subclass of
L<File::ChangeNotify::Watcher> and instantiates the first one it can
load, using the arguments you provided.

It always tries to use the L<File::ChangeNotify::Watcher::Default>
class last, on the assumption that any other class that is available
is a better option.

=head2 File::ChangeNotify->usable_classes()

Returns a list of all the loadable L<File::ChangeNotify::Watcher> subclasses
except for L<File::ChangeNotify::Watcher::Default>, which is always usable.

=head1 BUGS

Please report any bugs or feature requests to
C<bug-file-changenotify@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 DONATIONS

If you'd like to thank me for the work I've done on this module,
please consider making a "donation" to me via PayPal. I spend a lot of
free time creating free software, and would appreciate any support
you'd care to offer.

Please note that B<I am not suggesting that you must do this> in order
for me to continue working on this particular software. I will
continue to do so, inasmuch as I have in the past, for as long as it
interests me.

Similarly, a donation made in this way will probably not make me work
on this software much more, unless I get so many donations that I can
consider working on free software full time, which seems unlikely at
best.

To donate, log into PayPal and send money to autarch@urth.org or use
the button on this page:
L<http://www.urth.org/~autarch/fs-donation.html>

=cut
