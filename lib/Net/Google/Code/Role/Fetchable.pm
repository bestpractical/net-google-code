package Net::Google::Code::Role::Fetchable;
use Moose::Role;
use Params::Validate ':all';
use WWW::Mechanize;

has mech => (
    isa     => 'WWW::Mechanize',
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $m    = WWW::Mechanize->new(
            agent       => 'Net-Google-Code',
            cookie_jar  => {},
            stack_depth => 1,
            timeout     => 60,
        );
        return $m;
    }
);

sub fetch {
    my $self = shift;
    my ($url) = validate_pos( @_, { type => SCALAR } );
    $self->mech->get($url);
    if ( !$self->mech->response->is_success ) {
        die "Server threw an error "
          . $self->mech->response->status_line . " for "
          . $url;
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

Copyright 2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

