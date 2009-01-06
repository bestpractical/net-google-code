package Net::Google::Code::TicketComment;
use Moose;

has connection => (
    isa => 'Net::Google::Code::Connection',
    is  => 'ro',
    required => 1,
);

has updates   => ( isa => 'HashRef', is => 'rw', default => sub { {} } );
has author    => ( isa => 'Str',     is => 'rw' );
has date      => ( isa => 'Str',     is => 'rw' );
has content   => ( isa => 'Str',     is => 'rw' );
has sequence  => ( isa => 'Int',     is => 'rw' );
has attachments => (
    isa     => 'ArrayRef[Net::Google::Code::TicketAttachment]',
    is      => 'rw',
    default => sub { [] },
);

=head2 parse_entry

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

=cut

sub parse {
    my $self = shift;
    my $element = shift;
    my $author = $element->look_down( class => 'author' );
    my @a = $author->find_by_tag_name('a');
    $self->sequence( $a[0]->content_array_ref->[0] );
    $self->author( $a[1]->content_array_ref->[0] );
    $self->date( $element->look_down( class => 'date' )->attr_get_i('title') );
    my $content = $element->find_by_tag_name('pre')->as_text;
    $content =~ s/^\s+//;
    $content =~ s/\s+$/\n/;
    $content =~ s/\r\n/\n/g;
    $self->content( $content );

    my $updates = $element->look_down( class => 'updates' );
    if ( $updates ) {
        my $box_inner = $element->look_down( class => 'box-inner' );
        my $content = $box_inner->content_array_ref;
        while ( @$content ) {
            my $tag = shift @$content;
            my $value = shift @$content;
            shift @$content; # this is for the <br>

            my $key = $tag->content_array_ref->[0];
            $key =~ s/:$//;
            $value =~ s/^\s+//;
            $value =~ s/\s+$//;

            if ( $key eq 'Labels' ) {
# $value here is like "-Pri-2 -Area-Unknown Pri-3 Area-BrowserUI"
                my @items = split /\s+/, $value;

                for my $value (@items) {
                    if ( $value =~ /^-(.+)/ ) {
                        $value = $1;
                        if ( $value =~ /([^-]+?)-(.+)/ ) {
                            $self->updates->{labels}{$1}{old_value} = $2;
                        }
                        elsif ( $value =~ /([^-]+)$/ ) {
                            $self->updates->{labels}{$1}{old_value} = undef;
                        }
                        else {
                            warn "can't parse label from $value";
                        }
                    }
                    else {
                        if ( $value =~ /([^-]+?)-(.+)/ ) {
                            $self->updates->{labels}{$1}{new_value} = $2;
                        }
                        elsif ( $value =~ /([^-]+)$/ ) {
                            $self->updates->{labels}{$1}{new_value} = undef;
                        }
                        else {
                            warn "can't parse label from $value";
                        }
                    }
                }
            }
            else {
                $self->updates->{lc $key} = $value;
            }
        }

    }
    my $attachments = $element->look_down( class => 'attachments' );
    if ( $attachments ) {
        my @items = $attachments->find_by_tag_name( 'tr' );
        require Net::Google::Code::TicketAttachment;
        while ( scalar @items ) {
            my $tr1 = shift @items;
            my $tr2 = shift @items;
            my $a =
              Net::Google::Code::TicketAttachment->new(
                connection => $self->connection );

            if ( $a->parse( $tr1, $tr2 ) ) {
                push @{$self->attachments}, $a;
            }
        }
    }

    return 1;
}

no Moose;
1;

__END__

=head1 NAME

Net::Google::Code::TicketComment - 

=head1 DESCRIPTION

=head1 INTERFACE

=head2 parse

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

