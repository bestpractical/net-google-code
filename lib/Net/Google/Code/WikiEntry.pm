package Net::Google::Code::WikiEntry;

use Moose;
use Params::Validate qw(:all);
extends 'Net::Google::Code::Base';

our $VERSION = '0.02';
our $AUTHORITY = 'cpan:FAYLAND';

has name => ( is => 'ro', isa => 'Str', required => 1 );

has 'source' => (
    isa => 'Str',
    is  => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        return $self->fetch( $self->base_svn_url . 'wiki/' . $self->name . '.wiki' );
    }
);

has '__html' => (
    isa => 'Str',
    is  => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        # http://code.google.com/p/net-google-code/wiki/TestPage
        return $self->fetch( $self->base_url . 'wiki/' .  $self->name );
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

has 'updated_time' => (
    isa => 'Str',
    is  => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        my $tree = $self->__html_tree;
        return $tree->look_down(id => 'wikimaincol')->find_by_tag_name('td')
	    ->find_by_tag_name('span')->attr('title');
    },
);
has 'updated_by' => (
    isa => 'Str',
    is  => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        my $tree = $self->__html_tree;
        my $href = $tree->look_down(id => 'wikimaincol')->find_by_tag_name('td')
	    ->find_by_tag_name('a')->attr('href');
        my ( $author ) = ( $href =~ /u\/(.*?)\// );
        return $author;
    },
);

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::Google::Code::WikiEntry - Google Code Wiki Entry

=head1 SYNOPSIS

    use Net::Google::Code::Wiki;
    
    my $wiki = Net::Google::Code::Wiki->new( project => 'net-google-code' );

    my $wiki_entry = $wiki->entry('README');
    print $wiki_entry->source;

=head1 DESCRIPTION

get Wiki details from Google Code Project

=head1 ATTRIBUTES

=head2 source

wiki source code

=head2 html

html code of this wiki entry

=head2 updated_time

last updated time of this wiki entry

=head2 updated_by

last updator of this wiki entry

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
