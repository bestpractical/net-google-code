package Net::Google::Code::IssuePropChange;
use Moose;

has property  => ( isa => 'Str', is => 'rw' );
has old_value => ( isa => 'Str', is => 'rw' );
has new_value => ( isa => 'Str', is => 'rw' );

no Moose;
1;

__END__

=head1 NAME

Net::Google::Code::IssuePropChange - 

=head1 DESCRIPTION

=head1 INTERFACE

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

