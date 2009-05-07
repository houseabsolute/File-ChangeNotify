package File::ChangeNotify::Watcher;

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Params::Validate qw( pos_validated_list );

use Cwd qw( abs_path );
use File::Spec;
use FindBin;

has regex =>
    ( is      => 'ro',
      isa     => 'RegexpRef',
      default => sub { qr/.*/ },
    );

my $dir = subtype
       as 'Str'
    => where { -d $_ }
    => message { "$_ is not a valid directory" };

my $array_of_dirs = subtype
       as 'ArrayRef[Str]',
    => where { map { -d } @{$_} }
    => message { "@{$_} is not a list of valid directories" };

coerce $array_of_dirs
    => from $dir
    => via { [ $_ ] };

has directories =>
    ( is      => 'ro',
      isa     => $array_of_dirs,
      default => sub { [ abs_path( File::Spec->catdir( $FindBin::Bin, '..' ) ) ] },
      coerce  => 1,
    );

has follow_symlinks =>
    ( is      => 'ro',
      isa     => 'Bool',
      default => 0,
    );

has event_class =>
    ( is      => 'ro',
      ias     => 'ClassName',
      default => 'File::ChangeNotify::Event',
    );


sub BUILD
{
    my $self = shift;

    Class::MOP::load_class( $self->event_class() );
}

my $handler_type = duck_type ['handle_changes'];

sub watch
{
    my $self = shift;
    my ($handler) = pos_validated_list( \@_, $handler_type );

    my @events = $self->_wait_for_events();

    $handler->handle_events(@events);

    return;
}

sub new_events
{
    my $self = shift;

    return $self->_interesting_events();
}

sub _add_directory
{
    my $self = shift;
    my $dir  = shift;

    return if grep { $_ eq $dir } $self->directories();

    push @{ $self->directories() }, $dir;
}

sub _remove_directory
{
    my $self = shift;
    my $dir  = shift;

    $self->directories( [ grep { $_ ne $dir } @{ $self->directories() } ] );
}

no Moose;
no Moose::Util::TypeConstraints;
no MooseX::Params::Validate;

__PACKAGE__->meta()->make_immutable();

1;
