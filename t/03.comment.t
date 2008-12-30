use strict;
use warnings;

use Test::More tests => 6;

my $content;
{
        local $/;
        $content = <DATA>;
}

use HTML::TreeBuilder;
my $tree = HTML::TreeBuilder->new;
$tree->parse_content($content);
$tree->elementify;

use_ok( 'Net::Google::Code::TicketComment' );
my $comment = Net::Google::Code::TicketComment->new;
isa_ok( $comment, 'Net::Google::Code::TicketComment', '$comment' );
$comment->parse( $tree );

my %info = (
    sequence => 18,
    author   => 'jsykari',
    date     => 'Wed Sep  3 04:44:39 2008',
    content  => "haha\n",
);

for my $item ( keys %info ) {
    if ( defined $info{$item} ) {
        is ( $comment->$item, $info{$item}, "$item is extracted" );
    }
    else {
        ok( !defined $comment->$item, "$item is not defined" );
    }
}

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
 </table>
 
 </div>

 <div class="updates">
 <div class="round4"></div>
 <div class="round2"></div>
 <div class="round1"></div>
 <div class="box-inner">
 <b>Cc:</b> thatan...@google.com<br>
 </div>
 
 </td>

