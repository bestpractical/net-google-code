package Net::Google::Code::Ticket;
use Moose;
use Params::Validate qw(:all);

has id => (
    isa => 'Int',
    is  => 'rw',
);

has connection => (
    isa => 'Net::Google::Code::Connection',
    is  => 'ro',
    required => 1,
);

has state => (
    isa => 'HashRef',
    is  => 'rw',
    default => sub { {} },
);

has labels => (
    isa => 'HashRef',
    is  => 'rw',
    default => sub { {} },
);

has comments => (
    isa => 'ArrayRef',
    is => 'rw',
);

our @PROPS = qw(status owner closed cc summary description);

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
    require HTML::TreeBuilder;
    my $tree    = HTML::TreeBuilder->new;
    $tree->parse_content($content);
    $tree->elementify;
    my ($meta) = $tree->look_down( id => 'issuemeta' );
    my @meta = $meta->find_by_tag_name('tr');
    for my $meta (@meta) {

        my ( $key, $value );
        if ( my $k = $meta->find_by_tag_name('th') ) {
            my $v         = $meta->find_by_tag_name('td');
            my $k_content = $k->content_array_ref->[0];
            while ( ref $k_content ) {
                $k_content = $k_content->content_array_ref->[0];
            }
            $key = $k_content;    # $key is like 'Status:#'
            $key =~ s/:.$//;      # s/:#$// doesn't work, no idea why

            if ($v) {
                my $v_content = $v->content_array_ref->[0];
                while ( ref $v_content ) {
                    $v_content = $v_content->content_array_ref->[0];
                }
                $value = $v_content;
                $value =~ s/^\s+//;
                $value =~ s/\s+$//;
            }
            $self->state->{lc $key} = $value;
        }
        else {
            my $href = $meta->find_by_tag_name('a')->attr_get_i('href');

# from issue tracking faq:
# The prefix before the first dash is the key, and the part after it is the value.
            if ( $href =~ /list\?q=label:([^-]+?)-(.+)/ ) {
                ( $key, $value ) = ( $1, $2 );
            }
            elsif ( $href =~ /list\?q=label:([^-]+)$/ ) {
                $key = $1;
            }
            else {
                warn "can't parse label from $href";
            }
            $self->labels->{$key} = $value;
        }
    }

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

