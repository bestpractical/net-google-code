package Net::Google::Code::Connection;
use Moose;
use Params::Validate;
use Net::Google::Code::Mechanize;

has base_url => (
    isa => 'Str',
    is  => 'ro',
    default => 'http://code.google.com/p/',
);

has project => (
    isa => 'Str',
    is  => 'ro',
    required => 1,
);

has mech => (
    isa     => 'Net::Google::Code::Mechanize',
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $m    = Net::Google::Code::Mechanize->new();
        return $m;
    }
);

sub _fetch {
    my $self    = shift;
    my $query   = shift;
    my $abs_url;
    if ( $query =~ /^http(s)?:/ ) {
        $abs_url = $query;
    }
    else {
        $abs_url = $self->base_url . $self->project .  $query;
    }

    $self->mech->get($abs_url);
    $self->_die_on_error($abs_url);
    return $self->mech->content;
}

sub _die_on_error {
    my $self = shift;
    my $url  = shift;
    if ( !$self->mech->response->is_success ) {
        die "Server threw an error "
          . $self->mech->response->status_line . " for "
          . $url;
    }
    return
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Net::Google::Code::Connection - 


=head1 DESCRIPTION

=head1 INTERFACE

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

