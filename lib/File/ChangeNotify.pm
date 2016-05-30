package File::ChangeNotify;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '0.27';

use Carp qw( confess );

# We load this up front to make sure that the prereq modules are installed.
use File::ChangeNotify::Watcher::Default;
use Module::Pluggable::Object;
use Module::Runtime qw( use_module );

# First version to support coerce => 1
use Moo 1.006 ();

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
        return @usable_classes if $loaded;
        @usable_classes = grep { _try_load($_) }
            sort grep { $_ ne 'File::ChangeNotify::Watcher::Default' }
            $finder->plugins();
        $loaded = 1;

        return @usable_classes;
    }
}

sub _try_load {
    my $module = shift;

    my $ok = eval { use_module($module) };
    my $e = $@;
    return $module if $ok;

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

=cut
