package Net::Google::Code::Role;
use Moose::Role;
use Params::Validate;
use Net::Google::Code::Mechanize;

with 'Net::Google::Code::Role::Connectable';
with 'Net::Google::Code::Role::Authentication';
with 'Net::Google::Code::Role::HTMLTree';

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



no Moose::Role;

1;

__END__

=head1 NAME

Net::Google::Code::Role - 


=head1 DESCRIPTION

=head1 INTERFACE

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

