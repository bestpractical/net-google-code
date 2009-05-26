package Net::Google::Code::Role;
use Moose::Role;

with 'Net::Google::Code::Role::Fetchable';
with 'Net::Google::Code::Role::URL';
with 'Net::Google::Code::Role::HTMLTree';
with 'Net::Google::Code::Role::Authentication';
with 'Net::Google::Code::Role::DateTime';
with 'Net::Google::Code::Role::Pageable';

no Moose::Role;

1;

__END__

=head1 NAME

Net::Google::Code::Role - Role

=head1 DESCRIPTION

this is an aggregation role that includes all the roles.

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


