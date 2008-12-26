package Net::Google::Code::TicketComment;
use Moose;
use Net::Google::Code::TicketPropChange;

has connection => (
    isa => 'Net::Google::Code::Connection',
    is  => 'ro'
);

has prop_changes => ( isa => 'HashRef', is => 'rw' );

has author   => ( isa => 'Str',      is => 'rw' );
has date     => ( isa => 'DateTime', is => 'rw' );
has content  => ( isa => 'Str',      is => 'rw' );

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

sub parse_entry {
    my $self  = shift;
    my $entry = shift;
#XXX TODO

    return 1;
}

sub _parse_props {
    my $self       = shift;
    my $raw        = shift;
    my $props      = {};
#XXX TODO
    return $props;
}

no Moose;
1;

__END__

=head1 NAME

Net::Google::Code::TicketComment - 

=head1 DESCRIPTION

=head1 INTERFACE

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

