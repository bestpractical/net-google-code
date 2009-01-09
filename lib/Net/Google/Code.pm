package Net::Google::Code;

use Moose;
use Net::Google::Code::Connection;

our $VERSION = '0.02';

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
    default => sub { $_[0]->connection->base_url . $_[0]->project . '/' },
);

has 'svn_url' => (
    is => 'ro', isa => 'Str',
    default => sub { 'http://' . $_[0]->project . '.googlecode.com/svn/' },
);

has 'home'  => (
    isa     => 'Net::Google::Code::Home',
    is      => 'ro',
    lazy    => 1,
    default => sub {
        require Net::Google::Code::Home;
        Net::Google::Code::Home->new( parent => $_[0] );
    },
    handles => [ 'owners', 'members', 'summary', 'description', 'labels' ],
);

has 'issue' => (
    isa     => 'Net::Google::Code::Issue',
    is      => 'ro',
    lazy    => 1,
    default => sub {
        require Net::Google::Code::Issue;
        Net::Google::Code::Issue->new( connection => $_[0]->connection );
    }
);

has 'downloads' => (
    isa     => 'Net::Google::Code::Downloads',
    is      => 'ro',
    lazy    => 1,
    default => sub {
        require Net::Google::Code::Downloads;
        Net::Google::Code::Downloads->new( parent => $_[0] );
    }
);

has 'wiki' => (
    isa     => 'Net::Google::Code::Wiki',
    is      => 'ro',
    lazy    => 1,
    default => sub {
        require Net::Google::Code::Wiki;
        Net::Google::Code::Wiki->new( parent => $_[0] );
    }
);

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::Google::Code - a simple client library for google code

=head1 VERSION

This document describes Net::Google::Code version 0.02

=head1 SYNOPSIS

    use Net::Google::Code;
    
    my $project = Net::Google::Code->new( project => 'net-google-code' );
    
    print join(', ', @{ $project->owners } );
    
    $project->issue;
    $project->downloads;
    $project->wiki;

=head1 DESCRIPTION

Net::Google::Code is a simple client library for projects hosted in Google Code.

Currently, it focuses on the basic read functionality for that is provided.

=head1 ATTRIBUTES

=over 4

=item url

the project homepage

=item svn_url

the project svn url (without trunk)

=item summary

short Summary in 'Project Home'

=item description

HTML Description in 'Project Home'

=item labels

'Labels' in 'Project Home'

=item owners

ArrayRef. project owners

=item members

ArrayRef. project members

=back

=head1 METHODS

=over 4

=item issue

read L<Net::Google::Code::Issue> for the API detail

=item downloads

read L<Net::Google::Code::Downloads> for the API detail

=item wiki

read L<Net::Google::Code::Wiki> for the API detail

=over

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

Fayland Lam  C<< <fayland@gmail.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
