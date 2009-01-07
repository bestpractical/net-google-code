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
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Net::Google::Code - a simple client library for google code


=head1 VERSION

This document describes Net::Google::Code version 0.01


=head1 SYNOPSIS

    use Net::Google::Code::Connection;
    my $connection = Net::Google::Code::Connection( project => 'foo' );

    use Net::Google::Code::Issue;
    my $ticket = Net::Google::Code::Issue->new( connection => $connection );
    $ticket->load( 42 );

    use Net::Google::Code::IssueSearch;
    my $search = Net::Google::Code::IssueSearch->new( connection => $connection );
    $search->search( _can => 'all', _q => 'foo bar' );
    my @ids = $search->ids();


=head1 DESCRIPTION

Net::Google::Code is a simple client library for projects hosted in Google Code.

Currently, it focuses on the issue tracker, and the basic read functionality
for that is provided.

=head1 DEPENDENCIES

L<Moose>, L<HTML::TreeBuilder>, L<WWW::Mechanize>, L<Params::Validate>

=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

This project is very very young, and api is not stable yet, so don't use this in
production, at least for now.

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

