#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 15;
use Test::MockModule;
use FindBin qw/$Bin/;
use File::Slurp;

my $feed_file = "$Bin/sample/10.download.xml";
my $down_file = "$Bin/sample/10.download.html";

my $feed_content = read_file($feed_file);
my $download_content = read_file($down_file);

my $mock_connection = Test::MockModule->new('Net::Google::Code::Connection');
$mock_connection->mock(
    '_fetch',
    sub {
    	( undef, my $uri ) = @_;
    	if ( $uri eq 'http://code.google.com/feeds/p/net-google-code/downloads/basic' ) {
    		return $feed_content;
    	} elsif ( $uri eq 'http://code.google.com/p/net-google-code/downloads/detail?name=Net-Google-Code-0.01.tar.gz' ) {
    		return $download_content;
    	}
    }
);

use_ok('Net::Google::Code::Connection');
use_ok('Net::Google::Code::Downloads');
my $connection = Net::Google::Code::Connection->new( project => 'net-google-code' );
my $downloads = Net::Google::Code::Downloads->new( connection => $connection );
isa_ok( $downloads, 'Net::Google::Code::Downloads' );
isa_ok( $downloads->connection, 'Net::Google::Code::Connection' );

my @entries = $downloads->all_entries;
is( scalar @entries, 1 );
is $entries[0]->{filename}, 'Net-Google-Code-0.01.tar.gz';
is $entries[0]->{author}, 'sunnavy';
is $entries[0]->{size}, '37.4 KB';
is $entries[0]->{link}, 'http://code.google.com/p/net-google-code/downloads/detail?name=Net-Google-Code-0.01.tar.gz';

my $entry = $downloads->entry( 'Net-Google-Code-0.01.tar.gz' );
is $entry->{uploader}, 'sunnavy';
is $entry->{upload_time}, 'Tue Jan  6 00:16:06 2009';
is $entry->{download_count}, 6;
is $entry->{download_url}, 'http://net-google-code.googlecode.com/files/Net-Google-Code-0.01.tar.gz';
is $entry->{file_size}, '37.4 KB';
is $entry->{file_SHA1}, '5073de2276f916cf5d74d7abfd78a463e15674a1';

1;
