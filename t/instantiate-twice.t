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

ok(
    $watcher1->isa('File::ChangeNotify::Watcher'),
    'first isa File::ChangeNotify::Watcher'
);
ok(
    $watcher2->isa('File::ChangeNotify::Watcher'),
    'second isa File::ChangeNotify::Watcher'
);

done_testing();
