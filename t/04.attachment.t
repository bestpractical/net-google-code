use strict;
use warnings;

use Test::More tests => 5;

use Net::Google::Code::Issue::Attachment;
my $attachment = Net::Google::Code::Issue::Attachment->new( project => 'test' );
isa_ok( $attachment, 'Net::Google::Code::Issue::Attachment', '$attachment' );


my $content;
{
        local $/;
        $content = <DATA>;
}

use HTML::TreeBuilder;
my $tree = HTML::TreeBuilder->new;
$tree->parse_content($content);
$tree->elementify;

my @tr = $tree->find_by_tag_name('tr');
is( scalar @tr, 2, '@tr has 2 elements' );
$attachment->parse( $content );

my %info = (
    url =>
'http://chromium.googlecode.com/issues/attachment?aid=-1323983749556004507&name=proxy_settings.png',
    name => 'proxy_settings.png',
    size     => '14.3 KB',
);

for my $item ( keys %info ) {
    if ( defined $info{$item} ) {
        is ( $attachment->$item, $info{$item}, "$item is extracted" );
    }
    else {
        ok( !defined $attachment->$item, "$item is not defined" );
    }
}


__DATA__
 <tr><td rowspan="2" width="24"><a href="http://chromium.googlecode.com/issues/attachment?aid=-1323983749556004507&amp;name=proxy_settings.png" target="new"><img width="16" height="16" src="/hosting/images/generic.gif" border="0" ></a></td>
 <td><b>proxy_settings.png</b></td></tr>
 <tr><td>14.3 KB
  
 <a href="http://chromium.googlecode.com/issues/attachment?aid=-1323983749556004507&amp;name=proxy_settings.png">Download</a></td></tr>
