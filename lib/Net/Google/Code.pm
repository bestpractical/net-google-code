package Net::Google::Code;

use warnings;
use strict;
use Moose;

our $VERSION = '0.01';
use Net::Google::Code::Connection;

has 'project' => (
    isa      => 'Str',
    is       => 'ro',
    required => 1,
);

has 'connection' => (
    isa  => 'Net::Google::Code::Connection',
    is   => 'ro',
    lazy => 1,
    default =>
      sub { Net::Google::Code::Connection->new( project => $_[0]->project ) },
);

has 'url' => (
    isa     => 'Str',
    is      => 'ro',
    lazy    => 1,
    default => sub { $_[0]->connection->base_url . $_[0]->project . '/' },
);

has 'issue' => (
    isa     => 'Net::Google::Code::Issue',
    is      => 'rw',
    lazy    => 1,
    default => sub {
        require Net::Google::Code::Issue;
        Net::Google::Code::Issue->new( connection => $_[0]->connection );
    }
);

has 'downloads' => (
    isa     => 'Net::Google::Code::Downloads',
    is      => 'rw',
    lazy    => 1,
    default => sub {
        require Net::Google::Code::Downloads;
        Net::Google::Code::Downloads->new( connection => $_[0]->connection );
    }
);

has 'wiki' => (
    isa     => 'Net::Google::Code::Wiki',
    is      => 'rw',
    lazy    => 1,
    default => sub {
        require Net::Google::Code::Wiki;
        Net::Google::Code::Wiki->new( connection => $_[0]->connection );
    }
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

    use Net::Google::Code;
    my $project = Net::Google::Code->new( project => 'net-google-code' );
    $project->issue;
    $project->downloads;
    $project->wiki;

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

