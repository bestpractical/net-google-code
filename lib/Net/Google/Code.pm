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

    use Net::Google::Code::Connection;
    my $connection = Net::Google::Code::Connection( project => 'foo' );

    use Net::Google::Code::Issue;
    my $ticket = Net::Google::Code::Issue->new( connection => $connection );
    $ticket->load( 42 );

    use Net::Google::Code::Search;
    my $search = Net::Google::Code::Search->new( connection => $connection );
    $search->search( _can => 'all', _q => 'foo bar' );
    my @ids = $search->ids();


=head1 DESCRIPTION


=head1 INTERFACE



=head1 DEPENDENCIES


L<Moose>, L<HTML::TreeBuilder>, L<WWW::Mechanize>, L<Params::Validate>

=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

This project is very very young, api maybe changed, so don't use this in
production, at least for now.

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

