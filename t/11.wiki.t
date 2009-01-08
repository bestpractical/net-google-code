#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 7;
use Test::MockModule;
use FindBin qw/$Bin/;

my $svn_file = "$Bin/sample/11.wiki.html";

sub read_file {
	open(my $fh, '<', shift) or die $!;
	local $/;
	my $t = <$fh>;
	close($fh);
	return $t;
}

my $svn_content = read_file($svn_file);

my $mock_connection = Test::MockModule->new('Net::Google::Code::Connection');
$mock_connection->mock(
    '_fetch',
    sub {
    	( undef, my $uri ) = @_;
    	if ( $uri eq 'http://foorum.googlecode.com/svn/wiki/' ) {
    		return $svn_content;
    	}
    }
);

use_ok('Net::Google::Code::Connection');
use_ok('Net::Google::Code::Wiki');
my $connection = Net::Google::Code::Connection->new( project => 'foorum' );
my $wiki = Net::Google::Code::Wiki->new( connection => $connection );
isa_ok( $wiki, 'Net::Google::Code::Wiki' );
isa_ok( $wiki->connection, 'Net::Google::Code::Connection' );

my @entries = $wiki->all_entries;
is( scalar @entries, 16 );
is $entries[0], 'AUTHORS';
is_deeply(\@entries, ['AUTHORS', 'Configure', 'HowRSS', 'I18N', 'INSTALL', 'PreRelease',
	'README', 'RULES', 'TODO', 'TroubleShooting', 'Tutorial1', 'Tutorial2', 'Tutorial3',
	'Tutorial4', 'Tutorial5', 'Upgrade' ]);


1;