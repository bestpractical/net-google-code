package Net::Google::Code::Base;
use Moose;
with 'Net::Google::Code::Role::URL';
with 'Net::Google::Code::Role::Connectable';

has 'project' => (
    isa      => 'Str',
    reader   => '_project',
    required => 1,
);

=head2 project

# TODO Role's 'requires' can't work with attributes yet
# waiting for Moose's update

=cut

sub project { return shift->_project }

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

