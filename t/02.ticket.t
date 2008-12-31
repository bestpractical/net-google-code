use strict;
use warnings;

use Test::More tests => 18;
use Test::MockModule;

# $content is a real page: http://code.google.com/p/chromium/issues/detail?id=14
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
use_ok('Net::Google::Code::Ticket');
my $connection = Net::Google::Code::Connection->new( project => 'test' );
my $ticket = Net::Google::Code::Ticket->new( connection => $connection );
isa_ok( $ticket, 'Net::Google::Code::Ticket', '$ticket' );
isa_ok( $ticket->connection, 'Net::Google::Code::Connection', '$ticket->connection' );
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

my %labels = (
    Type   => 'Bug',
    Pri    => 2,
    OS     => 'All',
    Area   => 'Installer',
    intext => undef,
    Mstone => 'X',
    Foo    => 'Bar-Baz', # this is one we fake, for more than 1 hyphen
);

for my $item ( qw/id summary description owner cc reporter status closed/ ) {
    if ( defined $info{$item} ) {
        is ( $ticket->$item, $info{$item}, "$item is extracted" );
    }
    else {
        ok( !defined $ticket->$item, "$item is not defined" );
    }
}

is_deeply( $ticket->labels, \%labels, 'labels is extracted' );

is( scalar @{$ticket->comments}, 50, 'comments are extracted' );
is( $ticket->comments->[0]->sequence, 1, 'sequence of 1st comments is 1' );
# seems comments 2 and 3 are deleted
is( $ticket->comments->[1]->sequence, 4, 'sequence of 2nd comments is 4' ); 

# attachments part are faked from 
# http://code.google.com/p/chromium/issues/detail?id=683
is( scalar @{ $ticket->attachments }, 3, 'attachments are extracted' );
is( $ticket->attachments->[0]->size, '11.7 KB', 'size of the 1st attachment' );

__DATA__
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
 
 <title>Issue 14 - 
 chromium -
 
 Google Code</title>
 <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" >
 
 <link type="text/css" rel="stylesheet" href="http://www.gstatic.com/codesite/ph/3596478537346627501/css/d_20081117.css">
 
 
 
<!--[if IE]>
 <link type="text/css" rel="stylesheet" href="http://www.gstatic.com/codesite/ph/3596478537346627501/css/d_ie.css" >
<![endif]-->
</head>
<body class="t3">
 <div id="gaia">
  <font size="-1">
 
 <a href="/p/support/wiki/WhatsNew" style="color:#a03">What's new?</a>
 | <a href="/p/support/">Help</a>
 | <a href="/more/">Directory</a>
 | <a href="http://www.google.com/accounts/Login?continue=http%3A%2F%2Fcode.google.com%2Fp%2Fchromium%2Fissues%2Fdetail%3Fid%3D14&amp;followup=http%3A%2F%2Fcode.google.com%2Fp%2Fchromium%2Fissues%2Fdetail%3Fid%3D14">Sign in</a>
 
 </font> 

 </div>
 <div class="gbh" style="left: 0pt;"></div>
 <div class="gbh" style="right: 0pt;"></div>
 
 
 <div style="height: 1px"></div>
 <table style="padding:0px; margin: 20px 0px 0px 0px; width:100%" cellpadding="0" cellspacing="0">
 <tr>
 <td style="width:153px"><a href="/"><img src="http://www.gstatic.com/codesite/ph/images/code_sm.png" width="153" height="55" alt="Google"></a></td>
 <td style="padding-left: 0.8em">
 
 <div id="pname" style="margin: 0px 0px -3px 0px">
 <a href="/p/chromium/" style="text-decoration:none; color:#000">chromium</a>
 </div>
 <div id="psum">
 <i><a href="/p/chromium/" style="text-decoration:none; color:#000">An open-source browser project to help move the web forward.</a></i>
 </div>
 
 </td>
 <td style="white-space:nowrap; text-align:right">
 
 <form action="/hosting/search">
 <input size="30" name="q" value="">
 <input type="submit" name="projectsearch" value="Search Projects" >
 </form>
 
 </tr>
 </table>


<table id="mt" cellspacing="0" cellpadding="0" width="100%" border="0">
 <tr>
 <th onclick="if (!cancelBubble) _go('/p/chromium/');">
 <div class="tab inactive">
 <div class="round4"></div>
 <div class="round2"></div>
 <div class="round1"></div>
 <div class="box-inner">
 <a onclick="cancelBubble=true;" href="/p/chromium/">Project&nbsp;Home</a>
 </div>
 </div>
 </th><td>&nbsp;&nbsp;</td>
 
 
 
 
 
 
 <th onclick="if (!cancelBubble) _go('/p/chromium/w/list');">
 <div class="tab inactive">
 <div class="round4"></div>
 <div class="round2"></div>
 <div class="round1"></div>
 <div class="box-inner">
 <a onclick="cancelBubble=true;" href="/p/chromium/w/list">Wiki</a>
 </div>
 </div>
 </th><td>&nbsp;&nbsp;</td>
 
 
 
 
 
 <th onclick="if (!cancelBubble) _go('/p/chromium/issues/list');">
 <div class="tab active">
 <div class="round4"></div>
 <div class="round2"></div>
 <div class="round1"></div>
 <div class="box-inner">
 <a onclick="cancelBubble=true;" href="/p/chromium/issues/list">Issues</a>
 </div>
 </div>
 </th><td>&nbsp;&nbsp;</td>
 
 
 
 
 <td width="100%">&nbsp;</td>
 </tr>
</table>
<table cellspacing="0" cellpadding="0" width="100%" align="center" border="0" class="st">
 <tr>
 
 
 
 
 
 <td>
 <div class="issueDetail">
<div class="isf">
 
 
 <span class="inIssueEntry">
 <a href="entry">New Issue</a>
 </span> |
 
 <span class="inIssueList">
 <span>Search</span>
 <form action="list" method="GET" style="display:inline">
 <select id="can" name="can" style="font-size:92%">
 
<option disabled="disabled">Search Within:</option>
<option value="1" >&nbsp;All Issues</option>
<option value="2" selected=selected>&nbsp;Open Issues</option>

<option value="6" >&nbsp;New Issues</option>
<option value="7" >&nbsp;Issues to Verify</option>

 </select>
 <span>for</span>
 <input type="text" size="32" id="q" name="q" value="" style="font-size:92%" >
 
 <input type="hidden" name="colspec" id="search_colspec" value="ID Stars Pri Area Type Status Summary Modified Owner" >
 
 
 
 <input type="hidden" name="cells" value="tiles" >
 <input type="submit" value="Search" style="font-size:92%" >
 </form>
 </span> |
 <span class="inIssueAdvSearch">
 <a href="advsearch">Advanced Search</a>
 </span> |
 <span class="inIssueSearchTips">
 <a href="searchtips">Search Tips</a>
 </span>
</div>
</div>

 </td>
 
 
 
 
 
 
 <td height="4" align="right" valign="top" class="bevel-right">
 <div class="round4"></div>
 <div class="round2"></div>
 <div class="round1"></div>
 </td>
 </tr>
</table>
<script type="text/javascript">
 var cancelBubble = false;
 function _go(url) { document.location = url; }
</script>

<div id="maincol">
<!-- IE -->





 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

<style type="text/css">
 .attachments { width:33%; border-top:2px solid #999; padding-top: 3px}
 .attachments table { margin-bottom: 0.75em; }
 .attachments table tr td { padding: 0; margin: 0; font-size: 95%; }
 .label { white-space: nowrap; }
 .derived { font-style:italic }
</style>
<div id="issueheader">
<table cellpadding="0" cellspacing="0" width="100%"><tbody>
 <tr>
 <td class="vt h3" nowrap="nowrap" style="padding:0 5px">
 
 Issue <a href="detail?id=14">14</a>:
 </td>
 <td width="90%" class="vt">
 <span class="h3" >Proxy settings for installer</span>
 </td>
 <td>
 
 <div class="pagination">
 
 1 of 2665
 <a href="detail?id=17" title="Next">Next &rsaquo;</a>
 </div>
 </td>
 </tr>
 <tr>
 <td></td>
 <td nowrap="nowrap">
 
 
 34 people starred this issue and may be notified of changes.
 
 
 </td>
 <td align="center" nowrap="nowrap">
 
 <a href="http://code.google.com/p/chromium/issues/list">Back to list</a>
 
 </td>
 </tr>
</tbody></table>
</div><table width="100%" cellpadding="0" cellspacing="0" border="0" class="issuepage">
<tbody class="collapse"> 
 <tr>
 <td id="issuemeta" rowspan="1000"> 
 <table cellspacing="0" cellpadding="0">
 <tr><th align="left">Status:&nbsp;</th>
 <td width="100%">
 
 Available
 
 </td>
 </tr>
 
 
 
 <tr><th align="left">Owner:&nbsp;</th><td>
 
 <a href="/u/all-bugs-test@chromium.org/">all-bugs-test@chromium.org</a>
 
 </td>
 </tr>
 
 
 <tr><th class="vt" align="left">Cc:&nbsp;</th><td>
 
 
  <a href="/u/@VxJfQ1RWABBAXQE%3D/">thatan...@google.com</a> 
 
 </td></tr>
 
 
 
 <tr><td colspan="2">
 <a href="list?q=label:Type-Bug"
 title=""
 class="label"><b>Type-</b>Bug</a>
 </td></tr>
 
 
 
 <tr><td colspan="2">
 <a href="list?q=label:Pri-2"
 title=""
 class="label"><b>Pri-</b>2</a>
 </td></tr>
 
 
 
 <tr><td colspan="2">
 <a href="list?q=label:OS-All"
 title=""
 class="label"><b>OS-</b>All</a>
 </td></tr>
 
 
 
 <tr><td colspan="2">
 <a href="list?q=label:Area-Installer"
 title=""
 class="label"><b>Area-</b>Installer</a>
 </td></tr>
 
 
 
 <tr><td colspan="2"><a href="list?q=label:intext"
 title=""
 class="label">intext</a></td></tr>
 
 
 
 <tr><td colspan="2">
 <a href="list?q=label:Mstone-X"
 title=""
 class="label"><b>Mstone-</b>X</a>
 </td></tr>
 
 <tr><td colspan="2">
 <a href="list?q=label:Foo-Bar-Baz"
 title=""
 class="label"><b>Foo-</b>Bar-Bug</a>
 </td></tr>
 
 
 </table>
 <br><br>
 
 
 
 <div style="white-space:nowrap"><a href="http://www.google.com/accounts/Login?continue=http%3A%2F%2Fcode.google.com%2Fp%2Fchromium%2Fissues%2Fdetail%3Fid%3D14&amp;followup=http%3A%2F%2Fcode.google.com%2Fp%2Fchromium%2Fissues%2Fdetail%3Fid%3D14"
 >Sign in</a> to add a comment</div>
 
 
 
 
 <br>
 
 
 
  
 
 
 </td>
 <td class="vt issuedescription" width="100%">
 <div class="author">
 Reported by <a href="/u/seanamonroe/">seanamonroe</a>,
 <span class="date" title="Tue Sep  2 12:19:25 2008">Sep 02, 2008</span>
 </div>
<pre>
<b>What steps will reproduce the problem?</b>

Attempt to install chrome behind a firewall blocking HTTP/HTTPS traffic.

<b>What is the expected result?</b>

Options for proxy settings to allow the installer to retrieve the necessary
data via a proxy.

<b>What happens instead?</b>

Installer simply fails, notifying the user to adjust their firewall settings.
</pre>

 <div class="attachments">
 
 <table cellspacing="0" cellpadding="2" border="0">
 <tr><td rowspan="2" width="24"><a href="http://chromium.googlecode.com/issues/attachment?aid=-8682239133892813205&amp;name=chrome-border-bug.png"><img width="16" height="16" src="/hosting/images/generic.gif" border="0" ></a></td>
 <td><b>chrome-border-bug.png</b></td></tr>
 <tr><td>11.7 KB
  
 <a href="http://chromium.googlecode.com/issues/attachment?aid=-8682239133892813205&amp;name=chrome-border-bug.png">Download</a></td></tr>

 <tr><td rowspan="2" width="24"><a href="http://chromium.googlecode.com/issues/attachment?aid=-8682239133892813205&amp;name=chrome-border-bug.png"><img width="16" height="16" src="/hosting/images/generic.gif" border="0" ></a></td>
 <td><b>chrome-border-bug.png</b></td></tr>
 <tr><td>11.7 KB
  
 <a href="http://chromium.googlecode.com/issues/attachment?aid=-8682239133892813205&amp;name=chrome-border-bug.png">Download</a></td></tr>

 <tr><td rowspan="2" width="24"><a href="http://chromium.googlecode.com/issues/attachment?aid=-8682239133892813205&amp;name=chrome-border-bug.png"><img width="16" height="16" src="/hosting/images/generic.gif" border="0" ></a></td>
 <td><b>chrome-border-bug.png</b></td></tr>
 <tr><td>11.7 KB
  
 <a href="http://chromium.googlecode.com/issues/attachment?aid=-8682239133892813205&amp;name=chrome-border-bug.png">Download</a></td></tr>
 </table>

 
 </div>

 </td>
 </tr>
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c1"
 href="#c1">1</a>
 by
 <a href="/u/jakendall/">jakendall</a></span>,
 <span class="date" title="Tue Sep  2 12:20:16 2008">Sep 02, 2008</span>
<pre>
Firewall settings are taken from IE settings
</pre>
 
 
 </td>
 </tr>
 
 
 
 
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c4"
 href="#c4">4</a>
 by
 <a href="/u/seanamonroe/">seanamonroe</a></span>,
 <span class="date" title="Tue Sep  2 13:03:19 2008">Sep 02, 2008</span>
<pre>
Proxy is configured correctly in IE and IE is functional.

From looking at a packet capture it appears to be hitting the proxy, but failing
because the proxy requires authentication.
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c5"
 href="#c5">5</a>
 by
 <a href="/u/megatron3w/">megatron3w</a></span>,
 <span class="date" title="Tue Sep  2 13:30:09 2008">Sep 02, 2008</span>
<pre>
I'm having exact same issue. IE can access the net just fine behind our
Firewall/Proxy, thus I know the proxy is configured correctly. But the installer just
hangs unable to detect the proxy. I even tried using proxycfg in the command line and
that didn't make a difference either. 
</pre>
 
 
 </td>
 </tr>
 
 
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c7"
 href="#c7">7</a>
 by
 <a href="/u/nondisclosure007/">nondisclosure007</a></span>,
 <span class="date" title="Tue Sep  2 14:32:43 2008">Sep 02, 2008</span>
<pre>
I also have the same problem.
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c8"
 href="#c8">8</a>
 by
 <a href="/u/darklord00/">darklord00</a></span>,
 <span class="date" title="Tue Sep  2 14:47:09 2008">Sep 02, 2008</span>
<pre>
It would be a good idea if there was function implemented FF like, that let you 
define the proxy for Chrome no matter the IE settins dont you think?
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c9"
 href="#c9">9</a>
 by
 <a href="/u/sorinj/">sorinj</a></span>,
 <span class="date" title="Tue Sep  2 15:00:40 2008">Sep 02, 2008</span>
<pre>
If the proxy supports autologon using the negotiate protocol, then the installer will
work.
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c10"
 href="#c10">10</a>
 by
 <a href="/u/royer5563/">royer5563</a></span>,
 <span class="date" title="Tue Sep  2 15:06:24 2008">Sep 02, 2008</span>
<pre>
Alternate issue on this - 
Was able to download/install, but once instaleld, ti keeps asking for my 
login/password (proxy settings show same as my IE/Firefox settings which both work 
fine).
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c11"
 href="#c11">11</a>
 by
 <a href="/u/mgoffin/">mgoffin</a></span>,
 <span class="date" title="Tue Sep  2 15:12:31 2008">Sep 02, 2008</span>
<pre>
Same problem. I confirmed that both IE6, IE7, IE8B1, IE8B2, and Firefox are all 
functioning properly with my proxy. I was able to download and install without 
problems, but when browsing sites in Chrome I am constantly asked for proxy 
authentication. This also causes rendering issues for a lot of sites (Google Account 
Login, for instance).
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c12"
 href="#c12">12</a>
 by
 <a href="/u/danhood/">danhood</a></span>,
 <span class="date" title="Tue Sep  2 15:42:55 2008">Sep 02, 2008</span>
<pre>
Agree, it does not appear that there is any way to get the net installer (not the
browser itself) to pick up a proxy server.  If I recall correctly, this is also the
case with some of the other Google installers (i.e. newer releases of Google earth).

It would be nice to provide a non-net based installer so it could be downloaded with
a pre-configured browser and installed directly (or give the installers proxy support
similar to that of Cygwin).
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c13"
 href="#c13">13</a>
 by
 <a href="/u/zzygan/">zzygan</a></span>,
 <span class="date" title="Tue Sep  2 18:05:29 2008">Sep 02, 2008</span>
<pre>
Same issue here. I tried using the unix/firefox trick of specifing the username and
password in the proxy settings aka http://username:pass@proxy.settings.com but IE
just removes the username and pass.

</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c14"
 href="#c14">14</a>
 by
 <a href="/u/kaamelot.fr/">kaamelot.fr</a></span>,
 <span class="date" title="Tue Sep  2 22:48:09 2008">Sep 02, 2008</span>
<pre>
Same issue.
No way to specify the Proxy settings (Proxy Host, Port, User and Password) to Google
Update.
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c15"
 href="#c15">15</a>
 by
 <a href="/u/lasttimestealer/">lasttimestealer</a></span>,
 <span class="date" title="Wed Sep  3 00:07:19 2008">Sep 03, 2008</span>
<pre>
I was able to install Chrome behind a firewall but I can't get rid of the proxy
authentication. And I can enter whatever I like: Chrome does not accept my
authentication.
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c16"
 href="#c16">16</a>
 by
 <a href="/u/Nimlar/">Nimlar</a></span>,
 <span class="date" title="Wed Sep  3 00:25:04 2008">Sep 03, 2008</span>
<pre>
Maybe with the full event error message :

==========================================
The description for Event ID ( 20 ) in Source ( Google Update ) cannot be found. The
local computer may not have the necessary registry information or message DLL files
to display messages from a remote computer. You may be able to use the /AUXSOURCE=
flag to retrieve this description; see Help and Support for details. The following
information is part of the event: Network Request Error.
Error: 0x80042197. Http status code: 407.
Url=<a href="https://tools.google.com/service/update2">https://tools.google.com/service/update2</a>
Trying config: source=FireFox, wpad=0, script=http://************.com/
Trying CUP:WinHTTP.
Send request returned 0x80042197. Http status code 407.
Trying WinHTTP.
Send request returned 0x80042197. Http status code 407.
Trying CUP:Browser.
Send request returned 0x80004005. Http status code 0.
Trying config: source=IE, wpad=0, script=http://************.com
Trying CUP:WinHTTP.
Send request returned 0x80042197. Http status code 407.
Trying WinHTTP.
Send request returned 0x80042197. Http status code 407.
Trying CUP:Browser.
Send request returned 0x80004005. Http status code 0.
Trying config: source=winhttp, named proxy=*.************.com, bypass=.
Trying CUP:WinHTTP.
Send request returned 0x80072ee7. Http status code 0.
Trying WinHTTP.
Send request returned 0x80072ee7. Http status code 0.
Trying CUP:Browser.
Send request returned 0x80004005. Http status code 0.
======================================================

The proxy address taken from Firefox and IE are the same and the good one. But
Login/Password are never asked.
The config taken from &quot;source=winhttp&quot;, I don't know where it comes from, but
shouldn't work.


</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c17"
 href="#c17">17</a>
 by
 <a href="/u/james.bartley1985/">james.bartley1985</a></span>,
 <span class="date" title="Wed Sep  3 03:33:59 2008">Sep 03, 2008</span>
<pre>
Just to add.. I have the same problem.  I was able to install fine, just when run it 
asks for authentication even though it has the username and password saved in the 
boxes...
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c18"
 href="#c18">18</a>
 by
 <a href="/u/jsykari/">jsykari</a></span>,
 <span class="date" title="Wed Sep  3 04:44:39 2008">Sep 03, 2008</span>
<pre>
This may be related to the automatic configuration script used to configure the 
proxy.

On my system, ChromeSetup.exe gets stuck with &quot;Connecting to Internet&quot; with the proxy 
settings as in the attached screenshot (employer details censored).

When I remove the &quot;Use automatic configuration script&quot;, then ChromeSetup.exe works.

Chrome itself works both ways, it's the ChromeSetup.exe that fails on with the 
configuration script enabled.

== contents of proxy.pac == 
function FindProxyForURL(url, host) 
{
  if (isPlainHostName(host))
    return &quot;DIRECT&quot;;

  // Work
  if (isInNet(myIpAddress(), &quot;xxx.yyy.zzz.0&quot;, &quot;255.255.255.0&quot;)) 
    return &quot;PROXY cache.xxx.yyy:8888&quot;; 
  else 
    return &quot;DIRECT&quot;; 
}
== end contents of proxy.pac == 



</pre>
 
 <div class="attachments">
 
 <table cellspacing="0" cellpadding="2" border="0">
 <tr><td rowspan="2" width="24"><a href="http://chromium.googlecode.com/issues/attachment?aid=-1323983749556004507&amp;name=proxy_settings.png" target="new"><img width="16" height="16" src="/hosting/images/generic.gif" border="0" ></a></td>
 <td><b>proxy_settings.png</b></td></tr>
 <tr><td>14.3 KB
  
 <a href="http://chromium.googlecode.com/issues/attachment?aid=-1323983749556004507&amp;name=proxy_settings.png">Download</a></td></tr>
 </table>
 
 </div>

 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c19"
 href="#c19">19</a>
 by
 <a href="/u/fians4k/">fians4k</a></span>,
 <span class="date" title="Wed Sep  3 04:54:49 2008">Sep 03, 2008</span>
<pre>
Same proxy settings problem, keeps asking for username/password constantly, and even
when I write them over and over, the browser isn't downloading any data.

I guess 80% of work environments aren't going to use Chrome.
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c20"
 href="#c20">20</a>
 by
 <a href="/u/joao.dodigo/">joao.dodigo</a></span>,
 <span class="date" title="Wed Sep  3 05:48:21 2008">Sep 03, 2008</span>
<pre>
Também não estou conseguindo instalar mesmo com todas as configurações de proxy
inseridas corretamente.
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c21"
 href="#c21">21</a>
 by
 <a href="/u/deathwindfr/">deathwindfr</a></span>,
 <span class="date" title="Wed Sep  3 06:49:08 2008">Sep 03, 2008</span>
<pre>
I downloaded Chrome and installed it on my work computer. 
When I try to access a page it asks me for a proxy identification login/password
which I don't have. I use Firefox in the same settings and it works flawlessly so
there is an obvious bug.
I checked the settings for the proxy in IE, Forefox and Chrome and they are the same.
So I do not know why Chrome asks for a login when IE/Firefox do not.
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c22"
 href="#c22">22</a>
 by
 <a href="/u/isitive/">isitive</a></span>,
 <span class="date" title="Wed Sep  3 13:02:16 2008">Sep 03, 2008</span>
<pre>
i face the same problem. most of the work environments use proxy server settings 
...chrome doesn't gives an option to specify it like its given in Firefox.
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c23"
 href="#c23">23</a>
 by
 <a href="/u/bartosz.kulicki/">bartosz.kulicki</a></span>,
 <span class="date" title="Wed Sep  3 14:02:39 2008">Sep 03, 2008</span>
<pre>
Is your organization using Microsoft Proxy by any chance ? It has an option for NTLM
authentication (NT domain based auth). 

FF3 and IE support NTLM. Does Chrome support it ?

Unfortunately I can't test it myself (Win 200 here)  
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c24"
 href="#c24">24</a>
 by
 <a href="/u/KandyFLip/">KandyFLip</a></span>,
 <span class="date" title="Fri Sep  5 11:10:05 2008">Sep 05, 2008</span>
<pre>
Slightly different problem here, but possibly related.  We have an ISA 2000 proxy
which does not require any auth.  The installer used it just fine to download and
install.  However, the browser can't seem to use it at all.
My default settings are &quot;Automatically detect settings&quot; (DHCP gives location of wpad
script).
Tried changing to &quot;Use automatic configuration script&quot; and set the wpad location. 
Still nothing.
Tried manually setting the proxy.  Still nothing.
Changed to use a Squid proxy, which also does not require any authentication, and
still nothing.

All these settings work in IE and FF
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c25"
 href="#c25">25</a>
 by
 <a href="/u/bartosz.kulicki/">bartosz.kulicki</a></span>,
 <span class="date" title="Fri Sep  5 12:09:29 2008">Sep 05, 2008</span>
<pre>
From the description it sounds exactly like what I have here. 
I think your proxy requires NTLM auth but once you're logged on to NT domain
authentication is completely _transparent_ (FF and, of course, IE support this mode)

Other tickets here suggest Chrome does not support NTLM. As a workaround try wrapper
proxy like <a href="http://ntlmaps.sourceforge.net/">http://ntlmaps.sourceforge.net/</a>

chrome -&gt; ntlmaps -&gt; upstream_proxy
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c26"
 href="#c26">26</a>
 by
 <a href="/u/somekool/">somekool</a></span>,
 <span class="date" title="Sat Sep  6 07:10:27 2008">Sep 06, 2008</span>
<pre>
got proxy problem as well. even after installing chrome, i need to adjust the proxy
again.

see, in the windows internet config dialog, there is mainly two ways of setting a proxy.

1 - specifying a proxy address and port
2 - by using a connect script.

method 1 works fine with chrome. method 2, the connect script, does not seems to be
supported by google chrome. people at my work mostly use this method, so this is a
problem. 
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c27"
 href="#c27">27</a>
 by
 <a href="/u/somekool/">somekool</a></span>,
 <span class="date" title="Sat Sep  6 07:12:17 2008">Sep 06, 2008</span>
<pre>
same as bug #74 ?
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c28"
 href="#c28">28</a>
 by
 <a href="/u/igitur/">igitur</a></span>,
 <span class="date" title="Sat Sep  6 17:13:54 2008">Sep 06, 2008</span>
<pre>
Chrome itself doesn't support NTLM.  See <a title="Implement integrated windows authentication (aka NTLM / Negotiate Auth support)"  href="/p/chromium/issues/detail?id=19">issue#19</a> and <a title="Doesn't Support NTLM or Kerberos authentication of IIS served intranet pages" class=closed_ref href="/p/chromium/issues/detail?id=61"> issue#61 </a> (I think they are 
duplicates).

The proxy issue with the installer itself is probably a separate issue.

Weird, but I previously had the same problem the Google Gears installer. Initially, the 
installer couldn't connect through our corporate proxy.  I tried 2 months later and then it 
worked fine.  I assumed they fixed the bug.  Funny that Chrome's installer has the same 
issue then.
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c29"
 href="#c29">29</a>
 by
 <a href="/u/bothameister/">bothameister</a></span>,
 <span class="date" title="Sun Sep  7 06:45:10 2008">Sep 07, 2008</span>
<pre>
An offline installation file is available:
<a href="http://dl.google.com/chrome/install/149.27/chrome_installer.exe">http://dl.google.com/chrome/install/149.27/chrome_installer.exe</a>

It solved the proxy problem for me.

More details at <a href="http://www.winmatrix.com/forums/index.php?showtopic=19868">http://www.winmatrix.com/forums/index.php?showtopic=19868</a> 


</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c30"
 href="#c30">30</a>
 by
 <a href="/u/gonsas/">gonsas</a></span>,
 <span class="date" title="Tue Sep  9 13:30:57 2008">Sep 09, 2008</span>
<pre>
The offline installation file *does not* fix the problem, because after installation,
sites such as gmail.com fail to render correctly -- in this case, it fails to render
at all.
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c31"
 href="#c31">31</a>
 by
 <a href="/u/lloreto/">lloreto</a></span>,
 <span class="date" title="Tue Sep  9 18:25:26 2008">Sep 09, 2008</span>
<pre>
I have the same problem as above. After installing on my work machine, the browser is
unable to render any external site after proxy authentication.
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c32"
 href="#c32">32</a>
 by
 <a href="/u/lloreto/">lloreto</a></span>,
 <span class="date" title="Tue Sep  9 18:25:51 2008">Sep 09, 2008</span>
<pre>
I have the same problem as above. After installing on my work machine, the browser is
unable to render any external site after proxy authentication.
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c33"
 href="#c33">33</a>
 by
 <a href="/u/jirange/">jirange</a></span>,
 <span class="date" title="Wed Sep 10 06:17:09 2008">Sep 10, 2008</span>
<pre>
same problem but I want solution for this
</pre>
 
 
 </td>
 </tr>
 
 
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c35"
 href="#c35">35</a>
 by
 <a href="/u/ljpeixoto/">ljpeixoto</a></span>,
 <span class="date" title="Thu Sep 11 09:13:51 2008">Sep 11, 2008</span>
<pre>
I used ISACLient, it solved my problem:

<a href="http://groups.google.com/group/google-chrome-help-troubleshooting/browse_thread/thread/46cb8219c5b3b715/efaef6ce346271a9?lnk=raot">http://groups.google.com/group/google-chrome-help-troubleshooting/browse_thread/thread/46cb8219c5b3b715/efaef6ce346271a9?lnk=raot</a>

Unfortunately, it created a new problem: sometimes the browser gets the wrong images
- I believe the ISAServer somehow swapped the images.
It doesn´t seem like an chrome issue, because it happens in other browsers too, but
in IE I can press CTRL+F5 and it gets the correct image.

Well, I am using Windows XP SP1, maybe when I upgrade to XP SP2 (or SP3) it will
solve this new problem...
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c36"
 href="#c36">36</a>
 by
 <a href="/u/evan@chromium.org/">evan@chromium.org</a></span>,
 <span class="date" title="Thu Sep 11 11:06:23 2008">Sep 11, 2008</span>
<pre>
<i>(No comment was entered for this change.)</i>
</pre>
 
 
 <div class="updates">
 <div class="round4"></div>
 <div class="round2"></div>
 <div class="round1"></div>
 <div class="box-inner">
 <b>Status:</b> Untriaged<br><b>Labels:</b> -Area-Unknown Area-Installer<br>
 </div>
 <div class="round1"></div>
 <div class="round2"></div>
 <div class="round4"></div>
 </div>
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c37"
 href="#c37">37</a>
 by
 <a href="/u/pierceferriter/">pierceferriter</a></span>,
 <span class="date" title="Sat Sep 13 04:28:16 2008">Sep 13, 2008</span>
<pre>
I had the same problem at work. I had to change my proxy address from &quot;proxy&quot; to 
&quot;proxy.domain.com&quot; Which is strange as every other browser under the sun worked apart 
from Chrome. just need to be a bit more specific with it. Also this fix doesn't affect any other browsers.
</pre>
 
 
 </td>
 </tr>
 
 
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c39"
 href="#c39">39</a>
 by
 <a href="/u/helder.magalhaes/">helder.magalhaes</a></span>,
 <span class="date" title="Sat Sep 13 09:09:45 2008">Sep 13, 2008</span>
<pre>
As referred in comment 4, the problem is only located in the fact that the installer
itself doesn't support proxy authentication; the issue has little to do with the
proxy authentication support of Chrome which is working reasonably.

Tested using the offline installer download referred in comment 29: note that a more
recent installer [1] is available as of this writing.

[1] <a href="http://dl.google.com/chrome/install/149.29/chrome_installer.exe">http://dl.google.com/chrome/install/149.29/chrome_installer.exe</a>
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c40"
 href="#c40">40</a>
 by
 <a href="/u/google-chrome-owner@google.com/">google-chrome-owner@google.com</a></span>,
 <span class="date" title="Mon Sep 15 18:19:40 2008">Sep 15, 2008</span>
<pre>
b/1367980
</pre>
 
 
 <div class="updates">
 <div class="round4"></div>
 <div class="round2"></div>
 <div class="round1"></div>
 <div class="box-inner">
 <b>Labels:</b> intext<br>
 </div>
 <div class="round1"></div>
 <div class="round2"></div>
 <div class="round4"></div>
 </div>
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c41"
 href="#c41">41</a>
 by
 <a href="/u/daguerreroa/">daguerreroa</a></span>,
 <span class="date" title="Thu Sep 18 15:52:49 2008">Sep 18, 2008</span>
<pre>
For me the problem is with automatic configuration script. it works if i set the
proxy address and port manually.
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c42"
 href="#c42">42</a>
 by
 <a href="/u/bhagatamit85/">bhagatamit85</a></span>,
 <span class="date" title="Fri Sep 19 09:39:56 2008">Sep 19, 2008</span>
<pre>
I tried to use Google chrome for yahoo mail.It's working fine but while adding 
address in address bar when I tried to add the address by just typing the first few 
letters the address was not loaded automatically as that is loaded in Mozilla Firefox    
and Internet Explorer.
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c43"
 href="#c43">43</a>
 by
 <a href="/u/@VxJfQ1RWABBAXQE%3D/">thatan...@google.com</a></span>,
 <span class="date" title="Fri Oct  3 02:15:38 2008">Oct 03, 2008</span>
<pre>
<i>(No comment was entered for this change.)</i>
</pre>
 
 
 <div class="updates">
 <div class="round4"></div>
 <div class="round2"></div>
 <div class="round1"></div>
 <div class="box-inner">
 <b>Cc:</b> thatan...@google.com<br>
 </div>
 <div class="round1"></div>
 <div class="round2"></div>
 <div class="round4"></div>
 </div>
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c44"
 href="#c44">44</a>
 by
 <a href="/u/snowchyld/">snowchyld</a></span>,
 <span class="date" title="Wed Oct 22 11:04:39 2008">Oct 22, 2008</span>
<pre>
wpad.dat vs DHCP Option 252 

DHCP Option 252 is a URI to the proxy information
WPAD is an automated lookup, I believe chrome works for WPAD but not DHCP auto detect

any ideas ?
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c45"
 href="#c45">45</a>
 by
 <a href="/u/ben@chromium.org/">ben@chromium.org</a></span>,
 <span class="date" title="Wed Oct 22 14:14:56 2008">Oct 22, 2008</span>
<pre>
<i>(No comment was entered for this change.)</i>
</pre>
 
 
 <div class="updates">
 <div class="round4"></div>
 <div class="round2"></div>
 <div class="round1"></div>
 <div class="box-inner">
 <b>Status:</b> Available<br><b>Labels:</b> Mstone-X<br>
 </div>
 <div class="round1"></div>
 <div class="round2"></div>
 <div class="round4"></div>
 </div>
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c46"
 href="#c46">46</a>
 by
 <a href="/u/stijnsanders/">stijnsanders</a></span>,
 <span class="date" title="Thu Oct 23 02:05:46 2008">Oct 23, 2008</span>
<pre>
Is this issue the reason why I only get a microsoft-style 407 page from the ISA 
proxy when using mini_installer.exe (rev 3695), and not get prompted for my 
login/pwd? Or should I post this as a new issue?
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c47"
 href="#c47">47</a>
 by
 <a href="/u/donniel/">donniel</a></span>,
 <span class="date" title="Thu Oct 23 22:30:39 2008">Oct 23, 2008</span>
<pre>
Even worse: I was unable to start the installer from the Google Chrome download page! 
Clicking on the &quot;Accept and Install&quot; option causes the button to be grayed out, and 
the &quot;loading&quot; graphic to be shown. The installer never starts, however.

I'd managed to get Chrome installed earlier, but now can't upgrade/reinstall/update 
it on my work computer. Major fail.

Why don't you have a simple download link on the Chrome page? Is that too 
complicated?
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c48"
 href="#c48">48</a>
 by
 <a href="/u/Anselm.Meyn/">Anselm.Meyn</a></span>,
 <span class="date" title="Fri Oct 24 01:11:36 2008">Oct 24, 2008</span>
<pre>
Some general OT rants,

I think Chrome has been pretty much of disaster so far. Dont' understand why it was
released so early on, and the folks and googl don't seem to have been prepared
(management doing the old time-to-market crap maybe).
Anyway most folks I know, have pretty much abandoned it and gone back to trusty
Firefox (and even IE for that matter).

Really expected a lot more from googl and am very disappointed.
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c49"
 href="#c49">49</a>
 by
 <a href="/u/stijnsanders/">stijnsanders</a></span>,
 <span class="date" title="Fri Oct 24 02:56:21 2008">Oct 24, 2008</span>
<pre>
Though this comment thread is going way off topic, I can't leave this last post 
unanswered. I very much like Chrome. I think it's excellent. This issue preventing 
it to get through the proxy at work, is the -only- thing keeping me from using it at 
work, but at home I don't use anything else any more. It's not only magnitudes 
faster with (java)scripts and plugins, it's (finally!) using memory, resources, 
processes in a way that should have been all along. It's leaving out all of the 
fluff I don't use anyway, and provides what I do use in a way that feels natural, 
like we're used to Google doing for us. Keep up the good work guys! (and keep it 
open source)
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c50"
 href="#c50">50</a>
 by
 <a href="/u/@WRJWQlxRARlGXgB9/">pa...@escortvip.com.br</a></span>,
 <span class="date" title="Mon Oct 27 17:05:33 2008">Oct 27, 2008</span>
<pre>
i'will tri this

&lt;a href=&quot;http://www.escortvip.com.br&quot;&gt;acompanhantes&lt;/a
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c51"
 href="#c51">51</a>
 by
 <a href="/u/sectorx4/">sectorx4</a></span>,
 <span class="date" title="Sun Nov  2 16:56:40 2008">Nov 02, 2008</span>
<pre>
Due to the use of IE proxy settings whenever I restart Chrome I get asked for my 
proxy details in about 8 out of 20+ tabs, it's a minor annoyance but if the options 
for the proxy were within Chrome I imagine it would save people a whole lot of time.
</pre>
 
 
 </td>
 </tr>
 
 
 
 
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c54"
 href="#c54">54</a>
 by
 <a href="/u/marantz777/">marantz777</a></span>,
 <span class="date" title="Thu Dec  4 01:28:13 2008">Dec 04, 2008</span>
<pre>
I pray you... FIX THIS STUPID INSTALLER BUG !!!!

GoogleUpdate DOES NOT WORK in this condition

1- User is behibd a proxy (properly configured in IE7)
2- Proxy require explicit user/pwd credential prompted to the user

Most corporate users are in this situation, unable to install chrome with the tiny 
installer that download forever without requesting to user any credential. Also, full 
installers are very difficult to find.

chrome unusable for me, very disappointed....
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c55"
 href="#c55">55</a>
 by
 <a href="/u/helder.magalhaes/">helder.magalhaes</a></span>,
 <span class="date" title="Thu Dec  4 06:12:02 2008">Dec 04, 2008</span>
<pre>
(In reply to comment#54)
&gt; I pray you... FIX THIS STUPID INSTALLER BUG !!!!

This is not meant to sound aggressive, but consider getting a bit more familiarized
with netiquette [1] [2]... ;-)


&gt; GoogleUpdate DOES NOT WORK in this condition
&gt; 1- User is behibd a proxy (properly configured in IE7)
&gt; 2- Proxy require explicit user/pwd credential prompted to the user

There's some contradictory information on this. You affirm that this doesn't work,
information in comment#24 is compatible, but comment#41 affirms that using manual
settings works. One can take a look at what happened by looking at the event log
(Control Panel/Administrative Tools/Event Viewer/Application) such as in comment#16.
If an error occurs, the event should appear in the log after the attempt to open a
Web browser for the support page [3] (the instructions are also there).


&gt; Most corporate users are in this situation, unable to install chrome with the tiny 
&gt; installer that download forever without requesting to user any credential.

Download forever isn't expected. An error should pop about 2 minutes after the
&quot;Connecting to the Internet&quot; dialog is shown. If you are able to hold that long, of
course. ;-p


&gt; Also, full installers are very difficult to find.

Well, this is not as hard as it may seem: you may check the chrome releases blog [4]
and use the direct link (see comment#29) to download a particular dev/beta release,
just by replacing the &quot;XXX.XX&quot; for the two trailing numbers (&quot;154.31&quot;, for example)
of the release you intend do download:

  <a href="http://dl.google.com/chrome/install/XXX.XX/chrome_installer.exe">http://dl.google.com/chrome/install/XXX.XX/chrome_installer.exe</a>

This can be used as a workaround until this is improved/fixed.


Finally, <a title="Proxy authentication not supported for updates"  href="/p/chromium/issues/detail?id=2221">issue#2221</a> seems pretty related with this issue (although conceptually not
exactly the same so I guess there is no duplication).


Hope this helps,

 Helder Magalhães


[1] <a href="http://en.wikipedia.org/wiki/Netiquette">http://en.wikipedia.org/wiki/Netiquette</a>
[2] <a href="http://www.dtcc.edu/cs/rfc1855.html">http://www.dtcc.edu/cs/rfc1855.html</a>
[3] <a href="http://www.google.com/support/installer/bin/answer.py?answer=106640">http://www.google.com/support/installer/bin/answer.py?answer=106640</a>
[4] <a href="http://googlechromereleases.blogspot.com/">http://googlechromereleases.blogspot.com/</a>
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c56"
 href="#c56">56</a>
 by
 <a href="/u/anqara05/">anqara05</a></span>,
 <span class="date" title="Fri Dec 12 07:38:44 2008">Dec 12, 2008</span>
<pre>
When Chrome crashes and i reopen it, al lthe tabs populate but since i'm behind a 
proxy what allows internet access based on user accounts, it asks to authenticate 
again. then i have to refresh after authentication to load the pages.
to be exact the proxy server in this case is ISA2000. it doesn't seem, that chrome 
picks up my account info from my windows user session since i'm already logged in 
with an account that obviously has premission to access the internet thru the ISA 
server. other browsers don't have this problem.
</pre>
 
 
 </td>
 </tr>
 
 
 
 <tr>
 <td class="vt issuecomment">
 
 
 
 <span class="author">Comment <a name="c57"
 href="#c57">57</a>
 by
 <a href="/u/mal@chromium.org/">mal@chromium.org</a></span>,
 <span class="date" title="Fri Dec 19 17:59:29 2008">Dec 19, 2008</span>
<pre>
If you're having trouble with the downloader, please see this Help Center article for 
a link to a standalone installer:

<a href="http://www.google.com/support/installer/bin/answer.py?answer=126299">http://www.google.com/support/installer/bin/answer.py?answer=126299</a>
</pre>
 
 
 </td>
 </tr>
 
 


 
 <tr>
 <td class="vt issuecomment">
 <img width="10" height="12" src="http://www.gstatic.com/codesite/ph/images/triangle.gif"><a href="http://www.google.com/accounts/Login?continue=http%3A%2F%2Fcode.google.com%2Fp%2Fchromium%2Fissues%2Fdetail%3Fid%3D14&amp;followup=http%3A%2F%2Fcode.google.com%2Fp%2Fchromium%2Fissues%2Fdetail%3Fid%3D14"
 >Sign in</a> to add a comment
 </td>
 </tr>
 


</tbody>
</table>
<br>
<script type="text/javascript" src="http://www.gstatic.com/codesite/ph/3596478537346627501/js/dit_scripts_20081013.js"></script>




 


<form name="delcom" action="delComment.do?q=&amp;can=2&amp;sort=&amp;colspec=ID+Stars+Pri+Area+Type+Status+Summary+Modified+Owner" method="POST">
 <input type="hidden" name="sequence_num" value="">
 <input type="hidden" name="mode" value="">
 <input type="hidden" name="id" value="14">
 <input type="hidden" name="token" value="">
</form>
 <script type="text/javascript">
 _onload();
 function delComment(sequence_num, delete_mode) {
 var f = document.forms["delcom"];
 f.sequence_num.value = sequence_num;
 f.mode.value = delete_mode;
 
 f.submit();
 return false;
 }
 function ackVote() {
 var vote_feedback = document.getElementById('vote_feedback');
 if (!vote_feedback) return;
 var star2 = document.getElementById('star2');
 if (star2.src.indexOf('off.gif') != -1) {
 vote_feedback.innerHTML = 'Vote for this issue and get email change notifications.';
 } else {
 vote_feedback.innerHTML = 'Your vote has been recorded.';
 }
 }
 </script>
 
 <script type="text/javascript" src="http://www.gstatic.com/codesite/ph/3596478537346627501/js/core_scripts_20081103.js"></script>
 
 
 
 </div>
<div id="footer" dir="ltr">
 
 <div class="text">
 
 &copy;2008 Google -
 <a href="/">Code Home</a> -
 <a href="/tos.html">Terms of Service</a> -
 <a href="http://www.google.com/privacy.html">Privacy Policy</a> -
 <a href="/more/">Site Directory</a>
 
 </div>
</div>
<script type="text/javascript">
/**
 * Reports analytics.
 * It checks for the analytics functionality (window._gat) every 100ms
 * until the analytics script is fully loaded in order to invoke siteTracker.
 */
function _CS_reportAnalytics() {
 window.setTimeout(function() {
 if (window._gat) {
 var siteTracker = _gat._getTracker("UA-18071-1");
 siteTracker._initData();
 siteTracker._trackPageview();
 
 } else {
 _CS_reportAnalytics();
 }
 }, 100);
}
</script>

 
 


 
 </body>
</html>

