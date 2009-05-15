package Net::Google::Code::Role::Fetchable;
use Moose::Role;
use Params::Validate ':all';
use WWW::Mechanize;
use Encode;

has 'mech' => (
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
        my $content = $self->mech->content;
# auto decode the content to erase HTML::Parser's utf8 warning like this:
# Parsing of undecoded UTF-8 will give garbage when decoding entities
        return decode( 'utf8', $content );
    }
}

no Moose::Role;

1;

__END__

=head1 NAME

Net::Google::Code::Role::Fetchable - Fetchable Role


=head1 DESCRIPTION

=head1 INTERFACE

=over 4

=item fetch

=back

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

