#!/usr/bin/perl

use strict;
use warnings;
use Catalyst::Exception;

use Test::More tests => 8;
use lib 't/lib';
use LDAPTest;
use Storable qw/ freeze /;
use Test::Exception;

SKIP: {

    eval "use Catalyst::Model::LDAP";
    if ($@) {
        skip "Catalyst::Model::LDAP not installed", 8;
    }

    my $server = LDAPTest::spawn_server();

    use_ok("Catalyst::Authentication::Store::LDAP::Backend");

    my $back = Catalyst::Authentication::Store::LDAP::Backend->new(
        {   'ldap_server' => LDAPTest::server_host(),
            'binddn'      => 'anonymous',
            'bindpw'      => 'dontcarehow',
            'start_tls'   => 0,
            'user_basedn' => 'ou=foobar',
            'user_filter' => '(&(objectClass=person)(uid=%s))',
            'user_scope'  => 'one',
            'user_field'  => 'uid',
            'use_roles'   => 0,
            'user_class' => 'UserClass',
        }
    );

    isa_ok( $back, "Catalyst::Authentication::Store::LDAP::Backend" );
    my $user = $back->find_user( { username => 'somebody' } );
    isa_ok( $user, "Catalyst::Authentication::Store::LDAP::User" );
    isa_ok( $user, "UserClass");

    is( $user->my_method, 'frobnitz', "methods on user class work" );

    $server = LDAPTest::spawn_server();
    ok $user->check_password('foo'), 'Can check password';

    my $frozen_user;
    lives_ok { $frozen_user = freeze $user } 'Can freeze user with Storable';
    ok $frozen_user, 'is frozen';

}

