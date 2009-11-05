#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

plan skip_all => 'This test is only run for the module author'
    unless -d '.hg' || $ENV{IS_MAINTAINER};

eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage"
    if $@;

# This is a stripped down version of all_pod_coverage_ok which lets us
# vary the trustme parameter per module.
my @modules = all_modules();
plan tests => scalar @modules;

my %trustme = (
    'File::ChangeNotify::Watcher::Default' =>
        [qw( sees_all_events wait_for_events )],
    'File::ChangeNotify::Watcher::Inotify' =>
        [qw( sees_all_events wait_for_events )],
);

for my $module ( sort @modules ) {
    my @trustme = qr/^BUILD$/;

    if ( $trustme{$module} ) {
        my $methods = join '|', @{ $trustme{$module} };
        push @trustme, qr/^(?:$methods)$/;
    }

    pod_coverage_ok(
        $module, { trustme => \@trustme },
        "Pod coverage for $module"
    );
}
