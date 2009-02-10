package Net::Google::Code::Role::Authentication;
use Moose::Role;

with 'Net::Google::Code::Role::Connectable';

has 'email' => (
    isa => 'Str',
    is  => 'rw',
);

has 'password' => (
    isa => 'Str',
    is  => 'rw',
);

sub sign_in {
    my $self = shift;
    return 1 if $self->signed_in;
    $self->ask_password unless $self->password && length $self->password;

    my $already_in_google;
    if (
        $self->mech->follow_link(
            url_regex => qr!^https?://www\.google\.com/accounts/Login!
        )
      )
    {
        $already_in_google = 1;
    }
    else {
        $self->mech->get('https://www.google.com/accounts/Login');
    }

    $self->mech->submit_form(
        with_fields => {
            Email  => $self->email,
            Passwd => $self->password,
        },
    );

    die 'sign in failed to google code'
      unless ( $already_in_google && $self->mech->uri =~ /CheckCookie/ )
      || !$already_in_google && $self->html_contains(
        as_text   => qr/Sign out/i,
      );

    return 1;
}

sub sign_out {
    my $self = shift;
    $self->mech->follow_link(
        url_regex => qr!^https?://www\.google\.com/accounts/Logout! )
      || $self->mech->get('https://www.google.com/accounts/Logout');
    die 'sign out failed to google code'
      unless $self->html_contains(
        as_text   => qr/Sign in/i,
      );

    return 1;
}

sub ask_password {
    my $self = shift;
    while ( !defined $self->password or $self->password eq '' ) {
        require Term::ReadPassword;
        my $pass = Term::ReadPassword::read_password("password: ");
        $self->password($pass);
    }
}

sub signed_in {
    my $self = shift;
    return 1
      if $self->mech->content
          && $self->html_contains(
              as_text   => qr/Sign out/,
          );
    return;
}

no Moose::Role;

1;

__END__

=head1 NAME

Net::Google::Code::Role::Authentication - 

=head1 DESCRIPTION

=head1 INTERFACE


=head2 sign_in

sign in

=head2 sign_out

sign out

=head2 signed_in

return 1 if already signed in, return undef elsewise.

=head2 ask_password

ask user to input password

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


