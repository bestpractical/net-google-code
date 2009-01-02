package Net::Google::Code::Search;
use Moose;
use Params::Validate qw(:all);
use Net::Google::Code::Ticket;

has connection => (
    isa => 'Net::Google::Code::Connection',
    is  => 'ro',
    required => 1,
);

#our %CAN = (
#    'all'    => 1,
#    'open'   => 2,
#    'new'    => 6,
#    'verify' => 7,
#);

has '_can' => (
    is  => 'rw',
    isa => 'Int',
    default => 2,
);

has '_q' => ( 
    isa => 'Str',
    is => 'rw',
    default => '',
);

sub search {
    my $self = shift;
    my $mech = $self->connection->mech;
    $self->connection->_fetch('/issues/list');
    $mech->submit_form(
        form_number => 2,
        fields      => {
            'can' => $self->_can,
            'q'   => $self->_q,
        }
    );
    die "Server threw an error "
      . $mech->response->status_line
      . 'when search'
      unless $mech->response->is_success;

    my $content = $mech->content;

    if ( $mech->title =~ /Issue\s+\d+/ ) {
# only get one ticket
        my $ticket =
          Net::Google::Search::Ticket->new( connection => $self->connection );
        $ticket->parse($content);
        push @{$self->tickets}, $ticket;
    }
    elsif ( $mech->title =~ /Issues/ ) {
# get a ticket list
# XXX TODO parse the list

    }
    else {
        warn "no idea what the content like";
    }
}


no Moose;

1;

__END__

=head1 NAME

Net::Google::Code::Search - 


=head1 DESCRIPTION

=head1 INTERFACE

=head2 search

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

