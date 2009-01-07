package Net::Google::Code::IssueSearch;
use Moose;
use Params::Validate qw(:all);
use Moose::Util::TypeConstraints;

has connection => (
    isa => 'Net::Google::Code::Connection',
    is  => 'ro',
    required => 1,
);

our %CAN = (
    'all'    => 1,
    'open'   => 2,
    'new'    => 6,
    'verify' => 7,
);

subtype 'Can' => as 'Int' => where {
    my $v = $_;
    grep { $_ eq $v } values %CAN;
};
subtype 'CanStr' => as 'Str' => where { $CAN{$_} };
coerce 'Can' => from 'CanStr' => via { $CAN{$_} };

has '_can' => (
    is  => 'rw',
    isa => 'Can',
    default => 2,
);

has '_q' => ( 
    isa => 'Str',
    is => 'rw',
    default => '',
);

has 'ids' => (
    isa     => 'ArrayRef[Int]',
    is      => 'rw',
    default => sub { [] },
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

    my $content = $mech->response->content;

    if ( $mech->title =~ /Issue\s+(\d+)/ ) {
# only get one ticket
        @{$self->ids} = $1;
    }
    elsif ( $mech->title =~ /Issues/ ) {
# get a ticket list
        $self->ids([]); # clean previous ids

        require HTML::TreeBuilder;
        my $tree = HTML::TreeBuilder->new;
        $tree->parse_content($content);
        my $pagination = $tree->look_down( class => 'pagination' );
        if ( my ( $start, $end, $total ) =
            $pagination->content_array_ref->[0] =~
            /(\d+)\s+-\s+(\d+)\s+of\s+(\d+)/ )
        {

            my @ids = $tree->look_down( class => 'vt id col_0' );
            @ids =
              map { $_->content_array_ref->[0]->content_array_ref->[0] } @ids;
            push @{ $self->ids }, @ids;

            while ( scalar @{$self->ids} < $total ) {
                if ($mech->follow_link( text_regex => qr/Next\s+/ ) ) {
                    if ( $mech->response->is_success ) {
                        my $content = $mech->content;
                        my $tree    = HTML::TreeBuilder->new;
                        $tree->parse_content($content);
                        my @ids = $tree->look_down( class => 'vt id col_0' );
                        @ids =
                          map {
                            $_->content_array_ref->[0]->content_array_ref->[0]
                          } @ids;
                        push @{ $self->ids }, @ids;
                    }
                    else {
                        die "failed to follow link: Next";
                    }
                }
                else {
                # XXX sometimes google's result number is wrong. google--
                    warn "didn't find enough tickets, sometimes it's google's fault instead of ours ;)";
                    last;
                }
            }
        }

    }
    else {
        warn "no idea what the content like";
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Net::Google::Code::IssueSearch - 


=head1 DESCRIPTION

=head1 INTERFACE

=head2 search

=head2 ids

after search, this returns the ticket ids

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

