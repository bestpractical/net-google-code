use strict;
use warnings;

use Test::More tests => 21;
use Test::MockModule;

# $content is a real page: http://code.google.com/p/chromium/issues/detail?id=14
# we faked something to meet some situations, which are commented below

use FindBin qw/$Bin/;
use File::Slurp;

my $content = read_file( "$Bin/sample/02.issue.html" );
utf8::downgrade( $content, 1 );

my $mock = Test::MockModule->new('Net::Google::Code::Issue');
$mock->mock(
    'fetch',
    sub { $content }
);

my $mock_att = Test::MockModule->new('Net::Google::Code::Issue::Attachment');
$mock_att->mock( 'fetch', sub { '' } );

use Net::Google::Code::Issue;
my $issue = Net::Google::Code::Issue->new( project => 'test' );
isa_ok( $issue, 'Net::Google::Code::Issue', '$issue' );
$issue->load(14);

my $description = <<"EOF";
What steps will reproduce the problem?

Attempt to install chrome behind a firewall blocking HTTP/HTTPS traffic.

What is the expected result?

Options for proxy settings to allow the installer to retrieve the necessary
data via a proxy.

What happens instead?

Installer simply fails, notifying the user to adjust their firewall settings.
EOF

$description =~ s/\s+$//;

my %info = (
    id          => 14,
    summary     => 'Proxy settings for installer',
    description => $description,
    cc          => 'thatan...@google.com',
    owner       => 'all-bugs-test@chromium.org',
    reporter    => 'seanamonroe',
    status => 'Available',
    closed => undef,
);

my @labels = (
    'Type-Bug', 'Pri-2',    'OS-All', 'Area-Installer',
    'intext',   'Mstone-X', 'Foo-Bar-Baz',
);

for my $item ( qw/id summary description owner cc reporter status closed/ ) {
    if ( defined $info{$item} ) {
        is ( $issue->$item, $info{$item}, "$item is extracted" );
    }
    else {
        ok( !defined $issue->$item, "$item is not defined" );
    }
}

is_deeply( $issue->labels, \@labels, 'labels is extracted' );

is( scalar @{$issue->comments}, 51, 'comments are extracted' );
is( $issue->comments->[0]->sequence, 0, 'comment 0 is for the actual create' );
is( scalar @{ $issue->comments->[0]->attachments },
    3, 'comment 0 has 3 attachments' );
is_deeply(
    $issue->comments->[0]->updates,
    {
        'owner'   => 'all-bugs-test@chromium.org',
        'summary' => 'Proxy settings for installer',
        'labels' =>
          [ 'Area-Unknown', 'Type-Bug', 'Pri-2', 'OS-All', 'Foo-Bar-Baz' ]
    },
    'comment 0 updates'
);

is( $issue->comments->[1]->sequence, 1, 'sequence of comment 1 is 1' );
# seems comments 2 and 3 are deleted
is( $issue->comments->[2]->sequence, 4, 'sequence of comment 2 is 4' ); 

# attachments part are faked from 
# http://code.google.com/p/chromium/issues/detail?id=683
is( scalar @{ $issue->attachments }, 3, 'attachments are extracted' );
is( $issue->attachments->[0]->size, '11.7 KB', 'size of the 1st attachment' );

is( $issue->updated, '2008-12-20T01:59:29', 'updated' );


$content = read_file("$Bin/sample/02.issue_without_attachments.html");
utf8::downgrade( $content, 1 );
$issue->load(14);
is( $issue->updated, '2008-12-20T01:59:29', 'updated' );
is_deeply( $issue->attachments, [], 'no attachments are extracted' );
