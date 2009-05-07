package File::ChangeNotify::Watcher::Default;

use strict;
use warnings;

use Moose;

extends 'File::ChangeNotify::Watcher';

no Moose;

__PACKAGE__->meta()->make_immutable();
