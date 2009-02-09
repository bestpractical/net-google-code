package Net::Google::Code::IssueSearch;
use Moose;
use Params::Validate qw(:all);
use Moose::Util::TypeConstraints;
with 'Net::Google::Code::Role';

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
    if ( scalar @_ ) {
        my %args = @_;
        $self->_can( $args{_can} ) if defined $args{_can};
        $self->_q( $args{_q} ) if defined $args{_q};
    }

    $self->fetch('issues/list');
    my $mech = $self->mech;
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
        return 1;
    }
    elsif ( $mech->title =~ /Issues/ ) {
# get a ticket list
        $self->ids([]); # clean previous ids

        my $tree = $self->html_tree;
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
                        my $tree = $self->html_tree;
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
        return 1;
    }
    else {
        warn "no idea what the content like";
        return
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

=head2 search ( _can => 'all', _q = 'foo' )

search with values $self->_can and $self->_q if without arguments.
if there're arguments for _can or _q, this call will set $self->_can or
$self_q, then do the search.

return true if search is successful, false on the other hand.


=head2 ids
this should be called after a successful search.
returns issue ids as a arrayref.

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

