#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 12;
use Test::MockModule;
use FindBin qw/$Bin/;
use File::Slurp;
use_ok('Net::Google::Code');

my $homepage_file = "$Bin/sample/20.code.html";
my $homepage_content = read_file($homepage_file);

my $mock = Test::MockModule->new('Net::Google::Code');
$mock->mock(
    'fetch',
    sub {
    	( undef, my $uri ) = @_;
    	if ( $uri eq 'http://code.google.com/p/net-google-code/' ) {
    		return $homepage_content;
    	}
    }
);

my $name = 'net-google-code';
my $project = Net::Google::Code->new( project => $name );

is( $project->base_url, "http://code.google.com/p/$name/", 'default url' );
is( $project->base_svn_url, "http://$name.googlecode.com/svn/", 'svn url' );
is( $project->project, $name, 'project name' );

$project->load;
is_deeply( $project->owners, [ 'sunnavy' ] );
is_deeply( $project->members, [ 'jessev', 'fayland' ] );
like $project->description, qr/Net\:\:Google\:\:Code/;
is_deeply( $project->labels, [ 'perl', 'Google' ] );
is $project->summary, 'a simple client library for google code';

isa_ok( $project->issue,      'Net::Google::Code::Issue' );
isa_ok( $project->downloads,  'Net::Google::Code::Downloads' );
isa_ok( $project->wiki,       'Net::Google::Code::Wiki' );
