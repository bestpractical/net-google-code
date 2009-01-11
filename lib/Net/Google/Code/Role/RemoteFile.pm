package Net::Google::Code::Role::RemoteFile;
use Moose::Role;

has name    => ( isa => 'Str', is => 'rw' );
has url     => ( isa => 'Str', is => 'rw' );
has size    => ( isa => 'Str', is => 'rw' );
has content => ( isa => 'Str', is => 'rw' );

no Moose::Role;

1;

__END__

=head1 NAME

Net::Google::Code::Role::RemoteFile - 


=head1 DESCRIPTION

=head1 INTERFACE

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

