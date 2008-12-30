use strict;
use warnings;

use Test::More tests => 4;
use_ok('Net::Google::Code::Connection');
my $connection = Net::Google::Code::Connection->new( project => 'test' );
is( $connection->base_url, 'http://code.google.com/p/', 'default base_url' );
isa_ok( $connection->mech, 'Net::Google::Code::Mechanize' );

use Test::MockModule;

my $mech = Test::MockModule->new('Net::Google::Code::Mechanize');
my $resp = Test::MockModule->new('HTTP::Response');

$mech->mock( 'content',    sub { 'content' } );
$mech->mock( 'get',        sub {} );
$mech->mock( 'response',   sub { HTTP::Response->new } );
$resp->mock( 'is_success', sub { 1 } );

is( $connection->_fetch('blabla'), 'content', '_fetch' );
