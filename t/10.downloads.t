use strict;
use warnings;

use Test::More tests => 6;
use Test::MockModule;

# $content is a real page: http://code.google.com/feeds/p/net-google-code/downloads/basic
# we faked something to meet some situations, which are commented below

my $content;
{
        local $/;
        $content = <DATA>;
}


my $mock_connection = Test::MockModule->new('Net::Google::Code::Connection');
$mock_connection->mock(
    '_fetch',
    sub { $content }
);

use_ok('Net::Google::Code::Connection');
use_ok('Net::Google::Code::Downloads');
my $connection = Net::Google::Code::Connection->new( project => 'test' );
my $downloads = Net::Google::Code::Downloads->new( connection => $connection );
isa_ok( $downloads, 'Net::Google::Code::Downloads' );
isa_ok( $downloads->connection, 'Net::Google::Code::Connection', '$ticket->connection' );

my @entries = $downloads->all_entries;
is( scalar @entries, 1 );
is $entries[0]->{filename}, 'Net-Google-Code-0.01.tar.gz';

__DATA__
<?xml version="1.0"?>

<feed xmlns="http://www.w3.org/2005/Atom">
 <updated>2009-01-06T08:16:06Z</updated>
 <id>http://code.google.com/feeds/p/net-google-code/downloads/basic</id>
 <title>Downloads for project net-google-code on Google Code</title>
 <link rel="self" type="application/atom+xml;type=feed" href="http://code.google.com/feeds/p/net-google-code/downloads/basic"/>
 <link rel="alternate" type="text/html" href="http://code.google.com/p/net-google-code/downloads/list"/>
 
 <entry>
 <updated>2009-01-06T08:16:06Z</updated>
 <id>http://code.google.com/feeds/p/net-google-code/downloads/basic/Net-Google-Code-0.01.tar.gz</id>
 <link rel="alternate" type="text/html" href="http://code.google.com/p/net-google-code/downloads/detail?name=Net-Google-Code-0.01.tar.gz" />
 <title>
 Net-Google-Code-0.01.tar.gz (37.4 KB)
 </title>
 <author>
 <name>sunnavy</name>
 </author>
 <content type="html">

&lt;pre&gt;
Net-Google-Code-0.01

&lt;a href=&quot;http://net-google-code.googlecode.com/files/Net-Google-Code-0.01.tar.gz&quot;&gt;Download&lt;/a&gt;
&lt;/pre&gt;
 </content>
</entry>

 
</feed>
