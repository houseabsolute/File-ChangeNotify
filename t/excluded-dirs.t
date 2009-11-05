use strict;
use warnings;

use FindBin;
use File::ChangeNotify::Watcher;
use File::Spec;

use Test::More;

plan tests => 6;

my $root = File::Spec->catfile( $FindBin::Bin, '..' );
sub f { File::Spec->catfile( $root, @_ ) }

my $watcher = File::ChangeNotify::Watcher->new(
    directories => f(),
    exclude     => [
        f('foo'),
        f('bar'),
        f( 'excluded', 'dir' ),
        qr(/r[^/]+$),
        qr(/\.[^/]*$),
    ]
);

ok( !$watcher->_path_is_excluded( f('quux') ), 'included dir' );
ok( $watcher->_path_is_excluded( f('foo') ),   'excluded dir' );
ok( !$watcher->_path_is_excluded( f( 'foo', 'bar' ) ),
    'subdirs not excluded with string exclusion' );
ok( $watcher->_path_is_excluded( f( 'left', 'right' ) ),
    'excluded by regex' );
ok( $watcher->_path_is_excluded( f('.hidden') ),
    'excluding hidden dirs with regex' );
ok( !$watcher->_path_is_excluded( f( '.hidden', 'file' ) ),
    'hidden dir regex does not exclude subdirs' );
