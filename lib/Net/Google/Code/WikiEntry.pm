package Net::Google::Code::WikiEntry;

use Moose;
use Params::Validate qw(:all);

our $VERSION = '0.02';
our $AUTHORITY = 'cpan:FAYLAND';

has connection => (
    isa => 'Net::Google::Code::Connection',
    is  => 'ro',
    required => 1,
);

has name => ( is => 'ro', isa => 'Str', required => 1 );

has 'source' => (
    isa => 'Str',
    is  => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        my $name       = $self->name;
        my $connection = $self->connection;
        my $project    = $connection->project;
        
        my $wiki_url = "http://$project.googlecode.com/svn/wiki/$name.wiki";
        my $content = $connection->_fetch( $wiki_url );
        
        return $content;
    }
);

has '__html' => (
    isa => 'Str',
    is  => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        my $name       = $self->name;
        my $connection = $self->connection;
        my $project    = $connection->project;
        
        # http://code.google.com/p/net-google-code/wiki/TestPage
        my $wiki_url = "http://code.google.com/p/$project/wiki/$name";
        my $content = $connection->_fetch( $wiki_url );
        
        return $content;
    }
);

has '__html_tree' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        my $html = $self->__html;
        
        require HTML::TreeBuilder;
        my $tree = HTML::TreeBuilder->new;
        $tree->parse_content($html);
        $tree->elementify;
        
        return $tree;
    },
);

has 'html' => (
    isa => 'Str',
    is  => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        my $tree = $self->__html_tree;
        my $meta = $tree->look_down(id => 'wikimaincol');

        return $tree->content_array_ref->[-1]->as_HTML;
    },
);

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::Google::Code::WikiEntry - Google Code Wiki Entry

=head1 SYNOPSIS

    use Net::Google::Code::Connection;
    my $connection = Net::Google::Code::Connection( project => 'net-google-code' );

    use Net::Google::Code::WikiEntry;
    my $wiki_entry = Net::Google::Code::WikiEntry->new( connection => $connection, name => 'AUTHORS' );

=head1 DESCRIPTION

get Wiki details from Google Code Project

=head1 ATTRIBUTES

=head2 source

wiki source code

=head2 html

html code of this wiki entry

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
