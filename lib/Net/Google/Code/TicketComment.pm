package Net::Google::Code::TicketComment;
use Moose;
use Net::Google::Code::TicketPropChange;

has prop_changes => ( isa => 'HashRef',  is => 'rw' );
has author       => ( isa => 'Str',      is => 'rw' );
has date         => ( isa => 'Str', is => 'rw' );
has content      => ( isa => 'Str',      is => 'rw' );
has sequence     => ( isa => 'Int',      is => 'rw' );

=head2 parse_entry

parse format like(http://code.google.com/p/chromium/issues/detail?id=7#c1):

 <tr>
 <td class="vt issuecomment">
 <span class="author">Comment <a name="c1"
 href="#c1">1</a>
 by
 <a href="/u/tathagatadg/">tathagatadg</a></span>,
 <span class="date" title="Tue Sep  2 12:44:12 2008">Sep 02, 2008</span>
<pre>
My imports from Firefox 2.0.0.15 worked fine. Only required the open firefox to be 
closed. Import from IE 6 was smooth too.
</pre>
 </td>
 </tr>


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
# TODO parse prop_change
# TODO parse attachments

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

Copyright 2008 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

