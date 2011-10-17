#!/usr/bin/env perl

use strict;
use warnings;
use lib "t/lib";
use Test::More 'no_plan';

BEGIN{
  $ENV{DBIC_OVERWRITE_HELPER_METHODS_OK} = 1;
  $ENV{CATALYST_CONFIG} = 't/conf/abilities.yml';
  eval {
        require Test::WWW::Mechanize::Catalyst;
        require Catalyst::Plugin::Authorization::Roles;
        require Catalyst::Plugin::Authentication;
        require Catalyst::Plugin::Session;
        require Catalyst::Plugin::Session::State::Cookie;
    } or plan 'skip_all' => "A bunch of plugins are required for this test... Look in the source if you really care... $@";
};


use Test::WWW::Mechanize::Catalyst 'MyApp';

my $m = Test::WWW::Mechanize::Catalyst->new;

my $u = "http://localhost";
my $user = 'anonymous';


# anonymous can access to /
is_allowed("/");


# Must have right admin
is_denied("/admin");
is_denied("/admin/user");

is_denied("/with_role_admin");
is_denied("/with_role_member_and_moderator");
is_denied("/can_create_Page");
is_denied("/can_delete_Comment");


$user = 'admin';
login($m, $user, 'admin');

is_allowed("/admin");
is_allowed("/admin/user");

is_allowed("/with_role_admin");
is_allowed("/with_role_member_and_moderator");
is_allowed("/can_create_Page");
is_allowed("/can_delete_Comment");
is_allowed("/can_recursive_roles");


$user = 'joe';
login($m, $user, 'joe');

is_denied("/with_role_admin");
is_allowed("/with_role_member_and_moderator");
is_allowed("/can_create_Page");
is_allowed("/can_delete_Comment");
is_allowed("/can_recursive_roles");


$user = 'jack';
login($m, $user, 'jack');

is_denied("/with_role_admin");
is_denied("/with_role_member_and_moderator");
is_denied("/can_create_Page");
is_allowed("/can_delete_Comment");
is_denied("/can_recursive_roles");




sub is_denied {
        my $path = shift;
        $m->get("$u/$path", "get '$path'");
        $m->content_is("Access_denied !", "access to '$path' is denied");
}

sub is_allowed {
        my ( $path, $contains ) = @_;
        $path ||= "";
        $m->get_ok("$u/$path", "get '$path'");
}


sub login{
  my $mech  = shift;
  my $login = shift;
  my $pass  = shift;

  $mech->get_ok('http://localhost/login');
  $mech->form_with_fields(qw/username password/);
  $mech->field( username => $login );
  $mech->field( password => $pass);
  $mech->click('submit');
  $mech->content_contains("Welcome $user");
}



