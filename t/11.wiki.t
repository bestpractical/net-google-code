#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 14;
use Test::MockModule;
use FindBin qw/$Bin/;
use File::Slurp;
use Net::Google::Code;

my $svn_file   = "$Bin/sample/11.wiki.html";
my $wiki_file  = "$Bin/sample/11.TODO.wiki";
my $wiki_file2 = "$Bin/sample/11.TestPage.wiki";
my $entry_file = "$Bin/sample/11.wiki.TestPage.html";
my $svn_content   = read_file($svn_file);
my $wiki_content  = read_file($wiki_file);
my $wiki_content2 = read_file($wiki_file2);
my $entry_content = read_file($entry_file);

use Net::Google::Code::Wiki;

my $mock_sub = sub {
    	( undef, my $uri ) = @_;
    	if ( $uri eq 'http://foorum.googlecode.com/svn/wiki/' ) {
    		return $svn_content;
    	} elsif ( $uri eq 'http://foorum.googlecode.com/svn/wiki/TODO.wiki' ) {
    	    return $wiki_content;
    	} elsif ( $uri eq 'http://code.google.com/p/foorum/wiki/TestPage' ) {
    	    return $entry_content;
        } elsif ( $uri eq 'http://foorum.googlecode.com/svn/wiki/TestPage.wiki' ) {
    	    return $wiki_content2;
        }
};

my $mock_wiki = Test::MockModule->new('Net::Google::Code::Wiki');
$mock_wiki->mock( 'fetch', $mock_sub );

my $mock_wiki_entry = Test::MockModule->new('Net::Google::Code::WikiEntry');
$mock_wiki_entry->mock( 'fetch', $mock_sub );

my $wiki = Net::Google::Code::Wiki->new( project => 'foorum' );
isa_ok( $wiki, 'Net::Google::Code::Wiki' );

my @entries = $wiki->all_entries;
is( scalar @entries, 16 );
is $entries[0], 'AUTHORS';
is_deeply(\@entries, ['AUTHORS', 'Configure', 'HowRSS', 'I18N', 'INSTALL', 'PreRelease',
	'README', 'RULES', 'TODO', 'TroubleShooting', 'Tutorial1', 'Tutorial2', 'Tutorial3',
	'Tutorial4', 'Tutorial5', 'Upgrade' ]);

my $entry = $wiki->entry('TODO');
isa_ok( $entry, 'Net::Google::Code::WikiEntry' );

# test source
is $entry->source, $wiki_content;
is $entry->summary, 'TODO list';
is_deeply $entry->labels, ['Featured', 'Phase-Support'];

# test HTML
$entry = $wiki->entry('TestPage');
like $entry->html, qr/Add your content here/;
is $entry->updated_time, 'Sat Jan 17 15:21:27 2009';
is $entry->updated_by, 'fayland';
is $entry->summary, 'One-sentence summary of this page.';
is_deeply $entry->labels, ['Phase-QA', 'Phase-Support'];

is_deeply $entry->comments, [

{
    author => 'fayland',
    date   => 'Wed Jan  7 22:37:57 2009',
    content => '<p>comment1 </p>',
},
{
    author => 'fayland',
    date   => 'Wed Jan  7 22:38:07 2009',
    content => '<p>two line comment 2. </p>',
}

];

1;

