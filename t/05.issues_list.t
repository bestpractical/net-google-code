use strict;
use warnings;

use Test::More tests => 11;
use Test::MockModule;

use FindBin qw/$Bin/;
use File::Slurp;
my $content = read_file("$Bin/sample/05.issues_list.html");

my $mock = Test::MockModule->new('Net::Google::Code::Issue::Search');
$mock->mock( 'fetch', sub { $content } );
my $mock_mech = Test::MockModule->new('WWW::Mechanize');
$mock_mech->mock( 'title',       sub { 'issues' } );
$mock_mech->mock( 'submit_form', sub { } );
$mock_mech->mock( 'content',     sub { $content } );
$mock_mech->mock( 'is_success',  sub { 1 } );
$mock_mech->mock( 'response',    sub { HTTP::Response->new } );
my $mock_response = Test::MockModule->new('HTTP::Response');
$mock_response->mock( 'is_success', sub { 1 } );
$mock_response->mock( 'content',    sub { $content } );

use Net::Google::Code::Issue::Search;
my $search = Net::Google::Code::Issue::Search->new( project => 'test' );
$search->load_after_search(0);    # don't load after search
isa_ok( $search, 'Net::Google::Code::Issue::Search', '$search' );
$search->search();

is( scalar @{ $search->results }, 8, 'results number in total' );
my %first_result = (
    'owner'       => 'sunnavy',
    'attachments' => [],
    'summary'     => 'labels',
    'status'      => 'Accepted',
    'project'     => 'test',
    'id'          => '2',
    'labels'      => [],
    'comments'    => []
);

for my $key ( keys %first_result ) {
    is_deeply( $search->results->[0]->$key,
        $first_result{$key}, "first result $key" );
}

is_deeply( $search->results->[-1]->labels,
    [qw/0.05 blabla/], 'last result labels' );
