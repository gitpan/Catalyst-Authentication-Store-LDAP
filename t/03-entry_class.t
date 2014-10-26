#!/usr/bin/perl

use strict;
use warnings;
use Catalyst::Exception;

use Test::More tests => 6;
use lib 't/lib';
use LDAPTest;

SKIP: {

    eval "use Catalyst::Model::LDAP";
    if ($@) {
        skip "Catalyst::Model::LDAP not installed", 6;
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
            'entry_class' => 'EntryClass',
        }
    );

    isa_ok( $back, "Catalyst::Authentication::Store::LDAP::Backend" );
    my $user = $back->find_user( { username => 'somebody' } );
    isa_ok( $user, "Catalyst::Authentication::Store::LDAP::User" );
    my $displayname = $user->displayname;
    cmp_ok( $displayname, 'eq', 'Some Body', 'Should be Some Body' );

    isa_ok( $user->ldap_entry, "EntryClass", "entry_class works" );
    is( $user->ldap_entry->my_method, 1001, "methods on entry_class works" );

}
