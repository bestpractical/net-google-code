package Net::Google::Code::Issue::Comment;
use Moose;
use Net::Google::Code::Issue::Attachment;
with 'Net::Google::Code::Role::HTMLTree', 'Net::Google::Code::Role::DateTime';

has 'updates' => ( isa => 'HashRef', is => 'rw', default => sub { {} } );
has 'author'  => ( isa => 'Str',     is => 'rw' );
has 'date'    => ( isa => 'DateTime',     is => 'rw' );
has 'content' => ( isa => 'Str',     is => 'rw' );
has 'sequence' => ( isa => 'Int', is => 'rw' );
has 'attachments' => (
    isa     => 'ArrayRef[Net::Google::Code::Issue::Attachment]',
    is      => 'rw',
    default => sub { [] },
);

sub parse {
    my $self    = shift;
    my $element = shift;
    $element = $self->html_tree( html => $element ) unless blessed $element;

    my $author  = $element->look_down( class => 'author' );
    my @a       = $author->find_by_tag_name('a');
    $self->sequence( $a[0]->content_array_ref->[0] );
    $self->author( $a[1]->content_array_ref->[0] );
    $self->date($self->parse_datetime( $element->look_down( class => 'date' )->attr('title') ));
    my $content = $element->find_by_tag_name('pre')->as_text;
    $content =~ s/^\s+//;
    $content =~ s/\s+$/\n/;
    $content =~ s/\r\n/\n/g;
    $self->content($content);

    my $updates = $element->look_down( class => 'updates' );
    if ($updates) {
        my $box_inner = $element->look_down( class => 'box-inner' );
        my $content = $box_inner->content_array_ref;
        while (@$content) {
            my $tag   = shift @$content;
            my $value = shift @$content;
            if ( ref $value && $value->as_HTML =~ m!<br />! ) {
                # this happens when there's no value for $tag
                $value = '';
            }
            else {
                shift @$content;    # this is for the <br>
            }

            my $key = $tag->content_array_ref->[0];
            $key   =~ s/:$//;
            $value =~ s/^\s+//;
            $value =~ s/\s+$//;

            if ( $key eq 'Labels' ) {

               # $value here is like "-Pri-2 -Area-Unknown Pri-3 Area-BrowserUI"
                my @items = split /\s+/, $value;
                for my $value (@items) {
                    push @{$self->updates->{labels}}, $value;
                }
            }
            else {
                $self->updates->{ lc $key } = $value;
            }
        }

    }

    my $att_tag = $element->look_down( class => 'attachments' );
    my @attachments;

    @attachments =
      Net::Google::Code::Issue::Attachment->parse_attachments($att_tag)
      if $att_tag;
    $self->attachments( \@attachments );

    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Net::Google::Code::Issue::Comment - Issue's Comment

=head1 DESCRIPTION

=head1 INTERFACE

=over 4

=item parse( HTML::Element or html segment string )

parse format like the following:

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
 <b>Cc:</b> thatan...@google.com<br><b>Status:</b> Available<br><b>Labels:</b> Mstone-X<br>
 </div>
 <div class="round1"></div>
 <div class="round2"></div>
 <div class="round4"></div>
 </div>
 
 </td>

=back

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

