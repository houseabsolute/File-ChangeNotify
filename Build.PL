use strict;
use warnings;

use Module::Build;

my $builder =
    Module::Build->new
        ( module_name => 'File::ChangeNotify',
          license     => 'perl',
          requires    => { 'Carp'                           => '0',
                           'Class::MOP'                     => '0',
                           'Cwd'                            => '0',
                           'File::Find'                     => '0',
                           'File::Spec'                     => '0',
                           'FindBin'                        => '0',
                           'Module::Pluggable::Object'      => '0',
                           'Moose'                          => '0',
                           'MooseX::Params::Validate'       => '0',
                           'MooseX::SemiAffordanceAccessor' => '0',
                           'Time::HiRes'                    => '0',
                         },
          build_requires => { 'File::Path' => '0',
                              'File::Temp' => '0',
                              'Test::More' => '0',
                            },
          auto_features  =>
              { 'inotify' => { description => 'Inotify-based watcher',
                               requires    => { 'Linux::Inotify2' => '0' },
                             },
              },
          create_readme => 1,
          sign          => 1,
        );

$builder->create_build_script();
