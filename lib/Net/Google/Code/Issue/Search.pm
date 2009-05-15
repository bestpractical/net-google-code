package Net::Google::Code::Issue::Search;
use Moose;
use Params::Validate qw(:all);
use Moose::Util::TypeConstraints;
with 'Net::Google::Code::Role::URL',
  'Net::Google::Code::Role::Fetchable', 'Net::Google::Code::Role::Pageable',
  'Net::Google::Code::Role::HTMLTree';
use Net::Google::Code::Issue;

has 'project' => (
    isa      => 'Str',
    is       => 'rw',
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

has 'results' => (
    isa     => 'ArrayRef[Net::Google::Code::Issue]',
    is      => 'rw',
    default => sub { [] },
);

sub search {
    my $self = shift;
    if ( scalar @_ ) {
        my %args = @_;
        $self->_can( $args{_can} ) if defined $args{_can};
        $self->_q( $args{_q} )     if defined $args{_q};
    }

    $self->fetch( $self->base_url . 'issues/list' );
    my $mech = $self->mech;
    $mech->submit_form(
        form_number => 2,
        fields      => {
            'can' => $self->_can,
            'q'   => $self->_q,
        }
    );
    die "Server threw an error " . $mech->response->status_line . 'when search'
      unless $mech->response->is_success;

    my $content = $mech->response->content;

    if ( $mech->title =~ /Issue\s+(\d+)/ ) {
        # get only one ticket
        my $issue = Net::Google::Code::Issue->new( id => $1 );
        $self->results( [ $issue ] );
    }
    elsif ( $mech->title =~ /Issues/ ) {

        # get a ticket list
        my @ids = $self->first_columns($content);
        my @issues;
        for my $id ( @ids ) {
            my $issue = Net::Google::Code::Issue->new( id => $id );
            push @issues, $issue;
        }
        $self->results( \@issues );
    }
    else {
        warn "no idea what the content like";
        return;
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Net::Google::Code::Issue::Search - Issues Search API 


=head1 DESCRIPTION

=head1 INTERFACE

=over 4

=item search ( _can => 'all', _q = 'foo' )

search with values $self->_can and $self->_q if without arguments.
if there're arguments for _can or _q, this call will set $self->_can or
$self_q, then do the search.

return true if search is successful, false on the other hand.

=item project

=item results

this should be called after a successful search.
returns issues as a arrayref.

=back

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

