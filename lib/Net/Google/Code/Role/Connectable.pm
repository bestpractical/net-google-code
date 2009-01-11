package Net::Google::Code::Role::Connectable;
use Moose::Role;
use Params::Validate;
use Net::Google::Code::Mechanize;

with 'Net::Google::Code::Role::URL';

has mech => (
    isa     => 'Net::Google::Code::Mechanize',
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $m    = Net::Google::Code::Mechanize->new(
			agent       => 'Net-Google-Code',
            cookie_jar  => {},
            stack_depth => 1,
            timeout     => 60,
        );
        return $m;
    }
);

sub fetch {
    my $self    = shift;
    my $query   = shift;
    my $abs_url;
    if ( $query =~ /^http(s)?:/ ) {
        $abs_url = $query;
    }
    else {
        $abs_url = $self->base_url . $query;
    }

    $self->mech->get($abs_url);
    if ( !$self->mech->response->is_success ) {
        die "Server threw an error "
          . $self->mech->response->status_line . " for "
          . $abs_url;
    }
    else {
        return $self->mech->content;
    }
}

no Moose::Role;

1;

__END__

=head1 NAME

Net::Google::Code::Role::Connectable - 


=head1 DESCRIPTION

=head1 INTERFACE

=head2 fetch

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

