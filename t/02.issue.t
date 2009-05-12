use strict;
use warnings;

use Test::More tests => 17;
use Test::MockModule;

# $content is a real page: http://code.google.com/p/chromium/issues/detail?id=14
# we faked something to meet some situations, which are commented below

use FindBin qw/$Bin/;
use File::Slurp;

my $content = read_file( "$Bin/sample/02.issue.html" );

my $mock = Test::MockModule->new('Net::Google::Code::Issue');
$mock->mock(
    'fetch',
    sub { $content }
);

use Net::Google::Code::Issue;
my $ticket = Net::Google::Code::Issue->new( project => 'test' );
isa_ok( $ticket, 'Net::Google::Code::Issue', '$ticket' );
$ticket->load(14);

my $description = <<"EOF";
What steps will reproduce the problem?

Attempt to install chrome behind a firewall blocking HTTP/HTTPS traffic.

What is the expected result?

Options for proxy settings to allow the installer to retrieve the necessary
data via a proxy.

What happens instead?

Installer simply fails, notifying the user to adjust their firewall settings.
EOF

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

my @labels_array = map { $_ . '-' . ( $labels{$_} || '' ) } sort keys %labels;

for my $item ( qw/id summary description owner cc reporter status closed/ ) {
    if ( defined $info{$item} ) {
        is ( $ticket->$item, $info{$item}, "$item is extracted" );
    }
    else {
        ok( !defined $ticket->$item, "$item is not defined" );
    }
}

is_deeply( $ticket->labels, \@labels, 'labels is extracted' );
is_deeply(
    [ $ticket->labels_array ],
    \@labels_array,
    'labels_array without labels arg'
);
is_deeply(
    [ $ticket->labels_array( labels => { Type => 'foo', Label => 'bar' } ) ],
    [ 'Label-bar', 'Type-foo' ],
    'labels_array with labels arg'
);

is( scalar @{$ticket->comments}, 50, 'comments are extracted' );
is( $ticket->comments->[0]->sequence, 1, 'sequence of 1st comments is 1' );
# seems comments 2 and 3 are deleted
is( $ticket->comments->[1]->sequence, 4, 'sequence of 2nd comments is 4' ); 

# attachments part are faked from 
# http://code.google.com/p/chromium/issues/detail?id=683
is( scalar @{ $ticket->attachments }, 3, 'attachments are extracted' );
is( $ticket->attachments->[0]->size, '11.7 KB', 'size of the 1st attachment' );
