package Net::Google::Code::Ticket;
use Moose;
use Params::Validate qw(:all);

has id => (
    isa => 'Int',
    is  => 'rw',
    required => 1,
);

has connection => (
    isa => 'Net::Google::Code::Connection',
    is  => 'ro',
    required => 1,
);

has state => (
    isa => 'HashRef',
    is  => 'rw',
);

has comments => (
    isa => 'ArrayRef',
    is => 'rw',
);

our @PROPS = qw(status owner closed cc summary);

for my $prop (@PROPS) {
    no strict 'refs'; ## no critic
    *{ "Net::Google::Code::Ticket::" . $prop } = sub { shift->state->{$prop} };
}

=head2 load

=cut

sub load {
    my $self = shift;
    my ($id) = validate_pos( @_, { type => SCALAR } );
    $self->connection->_fetch( "/issues/detail?id=" . $id );

    my $content = $self->connection->mech->content;

    my $stateref;
    #XXX scrap $content to get state and comments

    return unless $stateref;
    $self->state( $stateref->{$id} );
    return $id;

}

sub _fetch_new_ticket_metadata {
    my $self = shift;

    #XXX TODO
    return 1;
}

no Moose;

1;

__END__

=head1 NAME

Net::Google::Code::Ticket - 


=head1 DESCRIPTION

=head1 INTERFACE

=head2 status

=head2 owner 

=head2 closed

=head2 cc

=head2 summary

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

