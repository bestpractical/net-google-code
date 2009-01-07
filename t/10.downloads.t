#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 9;
use Test::MockModule;
use FindBin qw/$Bin/;

# http://code.google.com/feeds/p/net-google-code/downloads/basic

my $feed_file = "$Bin/sample/10.download.xml";
my $down_file = "$Bin/sample/10.download.html";

sub read_file {
	open(my $fh, '<', shift) or die $!;
	local $/;
	my $t = <$fh>;
	close($fh);
	return $t;
}

my $feed_content = read_file($feed_file);
my $download_content = read_file($down_file);

my $mock_connection = Test::MockModule->new('Net::Google::Code::Connection');
$mock_connection->mock(
    '_fetch',
    sub {
    	( undef, my $uri ) = @_;
    	if ( $uri eq 'http://code.google.com/feeds/p/net-google-code/downloads/basic' ) {
    		return $feed_content;
    	} elsif ( $uri eq 'http://code.google.com/p/net-google-code/downloads/detail?name=Net-Google-Code-0.01.tar.gz#makechanges' ) {
    		return $download_content;
    	}
    }
);

use_ok('Net::Google::Code::Connection');
use_ok('Net::Google::Code::Downloads');
my $connection = Net::Google::Code::Connection->new( project => 'net-google-code' );
my $downloads = Net::Google::Code::Downloads->new( connection => $connection );
isa_ok( $downloads, 'Net::Google::Code::Downloads' );
isa_ok( $downloads->connection, 'Net::Google::Code::Connection', '$ticket->connection' );

my @entries = $downloads->all_entries;
is( scalar @entries, 1 );
is $entries[0]->{filename}, 'Net-Google-Code-0.01.tar.gz';
is $entries[0]->{author}, 'sunnavy';
is $entries[0]->{size}, '37.4 KB';
is $entries[0]->{link}, 'http://code.google.com/p/net-google-code/downloads/detail?name=Net-Google-Code-0.01.tar.gz';

my $entry = $downloads->entry( 'Net-Google-Code-0.01.tar.gz' );


1;