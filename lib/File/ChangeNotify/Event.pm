package File::ChangeNotify::Event;

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;

has path =>
    ( is       => 'ro',
      isa      => 'Str',
      required => 1,
    );

has event_type =>
    ( is       => 'ro',
      isa      => enum( [ qw( create modify delete unknown ) ] ),
      required => 1,
    );

no Moose;
no Moose::Util::TypeConstraints;

__PACKAGE__->meta()->make_immutable();

1;
