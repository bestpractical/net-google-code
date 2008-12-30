package Net::Google::Code::Ticket;
use Moose;
use Params::Validate qw(:all);
use Net::Google::Code::TicketComment;

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
    default => sub { [] },
);

our @PROPS = qw(id status owner closed cc summary reporter description);

for my $prop (@PROPS) {
    no strict 'refs'; ## no critic
    *{ "Net::Google::Code::Ticket::" . $prop } = sub { shift->state->{$prop} };
}

=head2 load

=cut

sub load {
    my $self = shift;
    my ($id) = validate_pos( @_, { type => SCALAR } );
    $self->state->{id} = $id;
    my $content = $self->connection->_fetch( "/issues/detail?id=" . $id );
    require HTML::TreeBuilder;
    my $tree    = HTML::TreeBuilder->new;
    $tree->parse_content($content);
    $tree->elementify;

    # extract summary
    my ($summary) = $tree->look_down(class => 'h3' );
    $self->state->{summary} = $summary->content_array_ref->[0];

    # extract reporter and description
    my $description = $tree->look_down(class => 'vt issuedescription' );
    $self->state->{reporter} =
      $description->look_down( class => "author" )->content_array_ref->[1]
      ->content_array_ref->[0];
    my $text = $description->find_by_tag_name('pre')->as_text;
    $text =~ s/^\s+//;
    $text =~ s/\s+$/\n/;
    $text =~ s/\r\n/\n/g;
    $self->state->{description} = $text;
    # TODO extract attachments if there are some

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

    # extract comments
    my @comments = $tree->look_down( class => 'vt issuecomment' );
    pop @comments;    # last one is for adding comment
    for my $comment (@comments) {
        my $object = Net::Google::Code::TicketComment->new;
        $object->parse($comment);
        push @{$self->comments}, $object;
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

=head2 id

=head2 status

=head2 owner 

=head2 reporter

=head2 closed

=head2 cc

=head2 summary

=head2 description

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

