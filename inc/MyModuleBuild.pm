package inc::MyModuleBuild;

use strict;
use warnings;

use Moose;

extends 'Dist::Zilla::Plugin::ModuleBuild';

around module_build_args => sub {
    my $orig = shift;
    my $self = shift;

    my $args = $self->$orig(@_);

    $args->{auto_features} = {
        Inotify => {
            description => 'Inotify support',
            requires    => { 'Linux::Inotify2' => '1.2' },
        },
        KQueue => {
            description => 'KQueue support',
            requires    => { 'IO::KQueue' => '0' },
        }
    };

    return $args;
};

__PACKAGE__->meta()->make_immutable();

1;
