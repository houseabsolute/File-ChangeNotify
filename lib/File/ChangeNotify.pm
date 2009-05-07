package File::ChangeNotify;

use strict;
use warnings;

our $VERSION = '0.01';

use Carp qw( confess );
use Class::MOP;
use Module::Pluggable::Object;

sub instantiate_watcher
{
    my $class = shift;

    for my $class ( $class->_all_classes() )
    {
        if ( Class::MOP::load_class($class) )
        {
            return $class->new(@_);
        }
    }

    die "Could not load a File::ChangeNotify::Watcher subclass (this should not happen, something is badly broken)";
}

sub usable_classes
{
    my $class = shift;

    return grep { _try_load($_) } $class->_all_classes();
}

sub _try_load
{
    my $class = shift;

    eval { Class::MOP::load_class($class) };

    my $e = $@;
    die $e if $e && $e !~ /Can\'t locate/;

    return $e ? 0 : 1;
}

my $finder =
    Module::Pluggable::Object->new( search_path => 'File::ChangeNotify::Watcher' );

sub _all_classes
{
    return sort _sort_classes $finder->plugins();
}

sub _sort_classes
{
      $a eq 'File::ChangeNotify::Watcher::Default'
    ? 1
    : $b eq 'File::ChangeNotify::Watcher::Default'
    ? -1
    : $a cmp $b;
}

1;

__END__

=pod

=head1 NAME

File::ChangeNotify - The fantastic new File::ChangeNotify!

=head1 SYNOPSIS

XXX - change this!

    use File::ChangeNotify;

    my $foo = File::ChangeNotify->new();

    ...

=head1 DESCRIPTION

=head1 METHODS

This class provides the following methods

=head1 AUTHOR

Dave Rolsky, E<gt>autarch@urth.orgE<lt>

=head1 BUGS

Please report any bugs or feature requests to C<bug-file-changenotify@rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org>.  I will be
notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Dave Rolsky, All Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
