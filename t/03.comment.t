use strict;
use warnings;

use Test::More tests => 9;

use Net::Google::Code::Issue::Comment;
use Test::MockModule;
my $comment =
  Net::Google::Code::Issue::Comment->new( project => 'test' );
isa_ok( $comment, 'Net::Google::Code::Issue::Comment', '$comment' );

my $mock = Test::MockModule->new('Net::Google::Code::Issue::Attachment');
$mock->mock(
    'fetch',
    sub { '' }
);

my $content;
{
        local $/;
        $content = <DATA>;
}

use HTML::TreeBuilder;
my $tree = HTML::TreeBuilder->new;
$tree->parse_content($content);
$tree->elementify;

$comment->parse( $tree );

my %info = (
    sequence => 18,
    author   => 'jsykari',
    date     => '2008-09-03T04:44:39',
    content  => "haha\n",
);

for my $item ( keys %info ) {
    if ( defined $info{$item} ) {
        is( $comment->$item, $info{$item}, "$item is extracted" );
    }
    else {
        ok( !defined $comment->$item, "$item is not defined" );
    }
}

my $updates = {
    cc     => 'thatan...@google.com',
    status => 'Available',
    labels => [ qw/-Pri-2 Mstone-X Pri-3/ ],
};

is_deeply( $updates, $comment->updates, 'updates are extracted' );

is( scalar @{$comment->attachments}, 2, 'attachments are extracted' );
is( $comment->attachments->[0]->name, 'proxy_settings.png', '1st attachment' );
is( $comment->attachments->[1]->name, 'haha.png', '2nd attachment' );

__DATA__
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c18"
 href="#c18">18</a>
 by
 <a href="/u/jsykari/">jsykari</a></span>,
 <span class="date" title="Wed Sep  3 04:44:39 2008">Sep 03, 2008</span>
<pre>
<b>haha</b>

</pre>
 
 <div class="attachments">
 
 <table cellspacing="0" cellpadding="2" border="0">
 <tr><td rowspan="2" width="24"><a href="http://chromium.googlecode.com/issues/attachment?aid=-1323983749556004507&amp;name=proxy_settings.png" target="new"><img width="16" height="16" src="/hosting/images/generic.gif" border="0" ></a></td>
 <td><b>proxy_settings.png</b></td></tr>
 <tr><td>14.3 KB
  
 <a href="http://chromium.googlecode.com/issues/attachment?aid=-1323983749556004507&amp;name=proxy_settings.png">Download</a></td></tr>
 <tr><td rowspan="2" width="24"><a href="http://chromium.googlecode.com/issues/attachment?aid=-1323983749556004507&amp;name=proxy_settings.png" target="new"><img width="16" height="16" src="/hosting/images/generic.gif" border="0" ></a></td>
 <td><b>haha.png</b></td></tr>
 <tr><td>20
  
 <a href="http://chromium.googlecode.com/issues/attachment?aid=-1323983749556004507&amp;name=proxy_settings.png">Download</a></td></tr>
 </table>
 
 </div>

 <div class="updates">
 <div class="round4"></div>
 <div class="round2"></div>
 <div class="round1"></div>
 <div class="box-inner">
 <b>Status:</b><br><b>Cc:</b> thatan...@google.com<br><b>Status:</b> Available<br><b>Labels:</b>-Pri-2 Mstone-X Pri-3<br>
 </div>
 <div class="round1"></div>
 <div class="round2"></div>
 <div class="round4"></div>
 </div>
 
 </td>

