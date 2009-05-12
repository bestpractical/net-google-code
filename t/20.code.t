#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 16;
use Test::MockModule;
use FindBin qw/$Bin/;
use File::Slurp;
use_ok('Net::Google::Code');

my $homepage_file     = "$Bin/sample/20.code.html";
my $homepage_content  = read_file($homepage_file);
my $downloads_file    = "$Bin/sample/10.downloads.xml";
my $downloads_content = read_file($downloads_file);
my $download_file     = "$Bin/sample/10.download.html";
my $download_content  = read_file($download_file);

my $mock = Test::MockModule->new('Net::Google::Code');
$mock->mock(
    'fetch',
    sub {
        shift;
        my $url = shift;
        if ( $url =~ /downloads/ ) {
            return $downloads_content;
        }
        else {
            return $homepage_content;
        }
    }
);
my $mock_downloads = Test::MockModule->new('Net::Google::Code::Download');
$mock_downloads->mock( 'fetch', sub { $download_content } );

my $name = 'net-google-code';
my $project = Net::Google::Code->new( project => $name );

is( $project->base_url, "http://code.google.com/p/$name/", 'default url' );
is( $project->base_svn_url, "http://$name.googlecode.com/svn/", 'svn url' );
is( $project->project, $name, 'project name' );

$project->load;
is_deeply( $project->owners, ['sunnavy'] );
is_deeply( $project->members, [ 'jessev', 'fayland' ] );
like $project->description, qr/Net\:\:Google\:\:Code/;
is_deeply( $project->labels, [ 'perl', 'Google' ] );
is $project->summary, 'a simple client library for google code';

isa_ok( $project->issue,    'Net::Google::Code::Issue' );
isa_ok( $project->download, 'Net::Google::Code::Download' );
isa_ok( $project->wiki,     'Net::Google::Code::Wiki' );

$project->load_downloads;
is( scalar @{ $project->load_downloads }, 1, 'have 1 download' );
my $download = $project->load_downloads->[0];
isa_ok( $download, 'Net::Google::Code::Download' );
is( $download->name, 'Net-Google-Code-0.01.tar.gz', 'download name' );
is( $download->size, '37.4 KB', 'download size' );
