use inc::Module::Install 0.77;

if ( -e 'MANIFEST.SKIP' ) {
    system( 'pod2text lib/Catalyst/Plugin/Authorization/Abilities.pm > README' );
}

perl_version '5.008';

name 'Catalyst-Plugin-Authorization-Abilities';
all_from 'lib/Catalyst/Plugin/Authorization/Abilities.pm';

requires 'Catalyst::Runtime'                => '5.7';
requires 'Catalyst::Plugin::Authentication' => '0.10003';
requires 'UNIVERSAL::isa'                   => '0.05';

test_requires 'Test::More';

auto_install;
WriteAll;
