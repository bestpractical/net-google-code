use strict;
use warnings;

use Test::More tests => 4;
use Net::Google::Code::Base;
my $base = Net::Google::Code::Base->new( project => 'test' );
is( $base->base_url, 'http://code.google.com/p/test/', 'base svn url' );
is( $base->base_svn_url, 'http://test.googlecode.com/svn/', 'base svn url' );
isa_ok( $base->mech, 'Net::Google::Code::Mechanize' );

use Test::MockModule;

my $mech = Test::MockModule->new('Net::Google::Code::Mechanize');
my $resp = Test::MockModule->new('HTTP::Response');

$mech->mock( 'content',    sub { 'content' } );
$mech->mock( 'get',        sub {} );
$mech->mock( 'response',   sub { HTTP::Response->new } );
$resp->mock( 'is_success', sub { 1 } );

is( $base->fetch('blabla'), 'content', 'fetch' );
