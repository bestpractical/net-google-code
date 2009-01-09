#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 8;
use_ok('Net::Google::Code');

my $name = 'net-google-code';
my $project = Net::Google::Code->new( project => $name );

is( $project->url, "http://code.google.com/p/$name/", 'default url' );
is( $project->svn_url, "http://$name.googlecode.com/svn/", 'svn url' );
is( $project->project, $name, 'project name' );

isa_ok( $project->connection, 'Net::Google::Code::Connection' );
isa_ok( $project->issue,      'Net::Google::Code::Issue' );
isa_ok( $project->downloads,  'Net::Google::Code::Downloads' );
isa_ok( $project->wiki,       'Net::Google::Code::Wiki' );
