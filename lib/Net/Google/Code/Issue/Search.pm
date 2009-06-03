package Net::Google::Code::Issue::Search;
use Any::Moose;
use Params::Validate qw(:all);
use Any::Moose 'Util::TypeConstraints';
with 'Net::Google::Code::Role::URL';
with 'Net::Google::Code::Role::Fetchable';
with 'Net::Google::Code::Role::Pageable';
with  'Net::Google::Code::Role::HTMLTree';
use Net::Google::Code::Issue;
use Encode;

our %CAN_MAP = (
    'all'    => 1,
    'open'   => 2,
    'new'    => 6,
    'verify' => 7,
);


has 'project' => (
    isa      => 'Str',
    is       => 'rw',
);

has 'results' => (
    isa     => 'ArrayRef[Net::Google::Code::Issue]',
    is      => 'rw',
    default => sub { [] },
);

sub search {
    my $self = shift;
    my %args = (
        limit             => 999_999_999,
        load_after_search => 1,
        can               => 2,
        @_
    );

    if ( $args{can} !~ /^\d$/ ) {
        $args{can} = $CAN_MAP{ $args{can} };
    }

    my $mech = $self->mech;
    my $url = $self->base_url . 'issues/list?';
    for my $type (qw/can q sort colspec/) {
        next unless defined $args{$type};
        $url .= $type . '=' . $args{$type} . ';';
    }
    $self->fetch( $url );

    die "Server threw an error " . $mech->response->status_line . 'when search'
      unless $mech->response->is_success;

    my $content = decode( 'utf8', $mech->response->content );

    if ( $mech->title =~ /issue\s+(\d+)/i ) {

         get only one ticket
        my $issue =
          Net::Google::Code::Issue->new( project => $self->project, id => $1, );
        $issue->load if $args{load_after_search};
        $self->results( [$issue] );
    }
    elsif ( $mech->title =~ /issues/i ) {

        # get a ticket list
        my @rows =
          $self->rows( html => $content, limit => $args{limit} );
        my @issues;
        for my $row (@rows) {
            my $issue = Net::Google::Code::Issue->new(
                project => $self->project,
                %$row,
            );
            $issue->load if $args{load_after_search};
            push @issues, $issue;
        }
        $self->results( \@issues );
    }
    else {
        warn "no idea what the content like";
        return;
    }
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Net::Google::Code::Issue::Search - Issues Search API 


=head1 DESCRIPTION

=head1 INTERFACE

=over 4

=item search ( can => 'all', q = 'foo', sort => '-modified' )

do the search, the results is set to $self->results,
  which is an arrayref with Net::Google::Code::Issue as element.

If a "sort" argument is specified, that will be passed to google code's issue list.
Generally, these are composed of "+" or "-" followed by a column name.

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

