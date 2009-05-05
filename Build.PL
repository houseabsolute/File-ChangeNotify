use strict;
use warnings;

use Module::Build;

my $builder = Module::Build->new
    ( module_name        => 'File::ChangeNotify',
      license            => 'perl',
      requires           => { },
      build_requires     => { 'Test::More' => '0',
                            },
      create_readme      => 1,
      sign               => 1,
    );

$builder->create_build_script();
