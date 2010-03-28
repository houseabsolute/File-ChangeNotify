use strict;
use warnings;

use Module::Build;

my $builder = Module::Build->new(
    module_name => 'File::ChangeNotify',
    license     => 'perl',
    requires    => {
        'Carp'                           => '0',
        'Class::MOP'                     => '0',
        'File::Find'                     => '0',
        'File::Spec'                     => '0',
        'Module::Pluggable::Object'      => '0',
        'Moose'                          => '0',
        'MooseX::Params::Validate'       => '0.08',
        'MooseX::SemiAffordanceAccessor' => '0',
        'Time::HiRes'                    => '0',
    },
    build_requires => {
        'File::Path' => '0',
        'File::Temp' => '0',
        'Test::More' => '0.88',
    },
    auto_features => {
        Inotify => {
            description => 'Inotify support',
            requires    => { 'Linux::Inotify2' => '1.2' },
        },
        KQueue => {
            description => 'KQueue support',
            requires    => { 'IO::KQueue' => '0' },
        },
    },
    create_readme      => 1,
    sign               => 1,
    create_makefile_pl => 'traditional',
    meta_merge         => {
        resources => {
            bugtracker =>
                'http://rt.cpan.org/NoAuth/Bugs.html?Dist=File-ChangeNotify',
            repository => 'http://hg.urth.org/hg/File-ChangeNotify',
        },
    },
);

$builder->create_build_script();
