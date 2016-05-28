use strict;
use warnings;

use Test::Requires {
    'Test::Without::Module' => 0,
};

use Test::More;
use Test::Without::Module qw( Linux::Inotify2 );

use File::ChangeNotify;

my $watcher1 = File::ChangeNotify->instantiate_watcher( directories => 't' );
my $watcher2 = File::ChangeNotify->instantiate_watcher( directories => 't' );

isa_ok(
    $watcher1,
    'File::ChangeNotify::Watcher',
    'first watcher'
);
isa_ok(
    $watcher2,
    'File::ChangeNotify::Watcher',
    'second watcher'
);

done_testing();
