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

has 'can' => (
    is      => 'rw',
    isa     => 'Can',
    coerce  => 1,
    default => 2,
);

has 'q' => (
    isa     => 'Str',
    is      => 'rw',
    default => '',
);


has 'sort' => (
    isa => 'Str',
    is => 'rw',
    default => ''
);

has 'colspec' => (
    isa     => 'Str',
    is      => 'rw',
    lazy    => 1,
    default => 'ID+Type+Status+Priority+Milestone+Owner+Summary+Modified',
);

has 'results' => (
    isa     => 'ArrayRef[Net::Google::Code::Issue]',
    is      => 'rw',
    default => sub { [] },
);

has 'limit' => (
    isa     => 'Int',
    is      => 'rw',
    default => 999_999_999,
);

has 'load_after_search' => (
    isa     => 'Bool',
    is      => 'rw',
    default => 1,
);

sub search {
    my $self = shift;
    if ( scalar @_ ) {
        my %args = @_;
        for my $attr (qw/can q limit sort colspec/) {
            $self->$attr( $args{$attr} )       if defined $args{$attr};
        }
        $self->load_after_search( $args{load_after_search} )
          if defined $args{load_after_search};
    }

    my $mech = $self->mech;
    my $url = $self->base_url . 'issues/list?';
    for my $attr ( qw/can q sort colspec/ ) {
        next unless defined $self->$attr;
        $url .= $attr . '=' . $self->$attr . ';';
    }
    $self->fetch( $url );

    die "Server threw an error " . $mech->response->status_line . 'when search'
      unless $mech->response->is_success;

    my $content = decode( 'utf8', $mech->response->content );

    if ( $mech->title =~ /issue\s+(\d+)/i ) {

         get only one ticket
        my $issue =
          Net::Google::Code::Issue->new( project => $self->project, id => $1, );
        $issue->load if $self->load_after_search;
        $self->results( [$issue] );
    }
    elsif ( $mech->title =~ /issues/i ) {

        # get a ticket list
        my @rows =
          $self->rows( html => $content, limit => $self->limit );
        my @issues;
        for my $row (@rows) {
            my $issue = Net::Google::Code::Issue->new(
                project => $self->project,
                %$row,
            );
            $issue->load if $self->load_after_search;
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

search with values $self->can and $self->q if without arguments.
if there're arguments, this call will set correspoding attributes or, then do the search.

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

