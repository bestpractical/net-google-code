package Net::Google::Code::WikiEntry;

use Moose;
use Params::Validate qw(:all);
with 'Net::Google::Code::Role';

our $VERSION = '0.03';
our $AUTHORITY = 'cpan:FAYLAND';

has name => ( is => 'ro', isa => 'Str', required => 1 );

has 'source' => (
    isa => 'Str',
    is  => 'ro',
    lazy => 1,
    predicate => 'has_source',
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

has 'summary' => (
    isa => 'Maybe[Str]',
    is  => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        if ( $self->has_source ) { # get from source
            my @lines = split(/\n/, $self->source);
            foreach my $line (@lines ) {
                if ( $line =~ /^\#summary\s+(.*?)$/ ) {
                    return $1;
                }
                last if ( $line !~ /^\#/ );
            }
            return;
        }
        # get from the html tree
        my $tree  = $self->__html_tree;
        my $title = $tree->find_by_tag_name('title')->content_array_ref->[0];
        my @parts = split(/\s+\-\s+/, $title, 4);
        return $parts[2] if ( scalar @parts == 4 );
        return;
    },
);

has 'labels' => (
    isa => 'ArrayRef',
    is  => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        if ( $self->has_source ) { # get from source
            my @lines = split(/\n/, $self->source);
            foreach my $line (@lines ) {
                if ( $line =~ /^\#labels\s+(.*?)$/ ) {
                    return [ split(/\,/, $1) ];
                }
                last if ( $line !~ /^\#/ );
            }
            return [];
        }
        # get from the html tree
        my $tree  = $self->__html_tree;
        my @tags = $tree->look_down( href => qr/q\=label\:/);
        my @labels;
        foreach my $tag ( @tags ) {
	        push @labels, $tag->content_array_ref->[0];
	    }
	    return \@labels;
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

=over 4

=item source

wiki source code

=item html

html code of this wiki entry

=item summary

summary of this wiki entry

=item labels

labels of this wiki entry

=item updated_time

last updated time of this wiki entry

=item updated_by

last updator of this wiki entry

=back

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
