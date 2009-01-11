#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 10;
use Test::MockModule;
use FindBin qw/$Bin/;
use File::Slurp;
use Net::Google::Code;

my $svn_file   = "$Bin/sample/11.wiki.html";
my $wiki_file  = "$Bin/sample/11.TODO.wiki";
my $entry_file = "$Bin/sample/11.wiki.TestPage.html";
my $svn_content   = read_file($svn_file);
my $wiki_content  = read_file($wiki_file);
my $entry_content = read_file($entry_file);

my $mock_connection = Test::MockModule->new('Net::Google::Code::Connection');
$mock_connection->mock(
    'fetch',
    sub {
    	( undef, my $uri ) = @_;
    	if ( $uri eq 'http://foorum.googlecode.com/svn/wiki/' ) {
    		return $svn_content;
    	} elsif ( $uri eq 'http://foorum.googlecode.com/svn/wiki/TODO.wiki' ) {
    	    return $wiki_content;
    	} elsif ( $uri eq 'http://code.google.com/p/foorum/wiki/TODO' ) {
    	    return $entry_content;
        }
    }
);

my $project = Net::Google::Code->new( project => 'foorum' );
my $wiki = $project->wiki;
isa_ok( $wiki, 'Net::Google::Code::Wiki' );
isa_ok( $wiki->parent, 'Net::Google::Code' );

my @entries = $wiki->all_entries;
is( scalar @entries, 16 );
is $entries[0], 'AUTHORS';
is_deeply(\@entries, ['AUTHORS', 'Configure', 'HowRSS', 'I18N', 'INSTALL', 'PreRelease',
	'README', 'RULES', 'TODO', 'TroubleShooting', 'Tutorial1', 'Tutorial2', 'Tutorial3',
	'Tutorial4', 'Tutorial5', 'Upgrade' ]);

my $entry = $wiki->entry('TODO');
isa_ok( $entry, 'Net::Google::Code::WikiEntry' );
is $entry->source, 'Please check [http://code.google.com/p/foorum/issues/list] for more issues.';
like $entry->html, qr/Add your content here/;
is $entry->updated_time, 'Wed Jan  7 22:32:44 2009';
is $entry->updated_by, 'fayland';

1;

