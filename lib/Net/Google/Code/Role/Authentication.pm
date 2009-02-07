package Net::Google::Code::Role::Authentication;
use Moose::Role;

with 'Net::Google::Code::Role::Connectable';

has 'email' => (
    isa => 'Str',
    is  => 'rw',
);

has 'password' => (
    isa       => 'Str',
    is        => 'rw',
    predicate => 'has_password',
);


sub signin {
    my $self = shift;
    $self->ask_password unless $self->has_password;

    $self->mech->get('https://www.google.com/accounts/Login');
    $self->mech->submit_form(
        with_fields => {
            Email  => $self->email,
            Passwd => $self->password,
        },
    );

    die 'signin failed to google code'
      unless $self->mech->content =~ m!Sign Out!;

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

no Moose::Role;

1;

__END__

=head1 NAME

Net::Google::Code::Role::Authentication - 

=head1 DESCRIPTION

=head1 INTERFACE


=head2 signin

sign in

=head2 ask_password

ask user to input password

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


