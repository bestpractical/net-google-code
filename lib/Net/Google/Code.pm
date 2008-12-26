package Net::Google::Code;

use warnings;
use strict;
use Moose;

our $VERSION = '0.01';

has 'project' => (
    isa      => 'Str',
    required => 1,
);


no Moose;

1;

__END__

=head1 NAME

Net::Google::Code - 


=head1 VERSION

This document describes Net::Google::Code version 0.0.1


=head1 SYNOPSIS

    use Net::Google::Code;

=head1 DESCRIPTION


=head1 INTERFACE



=head1 DEPENDENCIES


None.


=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

