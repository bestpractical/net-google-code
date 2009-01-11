package Net::Google::Code::Home;

use Moose;

our $VERSION = '0.02';
our $AUTHORITY = 'cpan:FAYLAND';

extends 'Net::Google::Code::Base';


has '__html' => (
    isa => 'Str',
    is  => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        return $self->fetch( $self->base_url );
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

has 'owners' => (
    isa => 'ArrayRef',
    is  => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        my $tree = $self->__html_tree;
        my @tags = $tree->look_down(id => 'owners')->find_by_tag_name('a');
        my @owners;
        foreach my $tag ( @tags ) {
	        push @owners, $tag->content_array_ref->[0];
	    }
	    return \@owners;
    },
);
has 'members' => (
    isa => 'ArrayRef',
    is  => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        my $tree = $self->__html_tree;
        my @tags = $tree->look_down(id => 'members')->find_by_tag_name('a');
        my @members;
        foreach my $tag ( @tags ) {
	        push @members, $tag->content_array_ref->[0];
	    }
	    return \@members;
    },
);

has 'summary' => (
    isa => 'Str',
    is  => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        my $tree = $self->__html_tree;
        return $tree->look_down(id => 'psum')->find_by_tag_name('a')->content_array_ref->[0];
    },
);

has 'description' => (
    isa => 'Str',
    is  => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        my $tree = $self->__html_tree;
        return $tree->look_down(id => 'wikicontent')->content_array_ref->[0]->as_HTML;
    },
);

has 'labels' => (
    isa => 'ArrayRef',
    is  => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        my $tree = $self->__html_tree;
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

Net::Google::Code::Home - 

=head1 DESCRIPTION

used by L<Net::Google::Code>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
