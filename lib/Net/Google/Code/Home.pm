package Net::Google::Code::Home;

use Moose;

our $VERSION = '0.02';
our $AUTHORITY = 'cpan:FAYLAND';

has parent => (
    isa => 'Net::Google::Code',
    is  => 'ro',
    required => 1,
);

has '__html' => (
    isa => 'Str',
    is  => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        my $connection = $self->parent->connection;
        
        my $content = $connection->_fetch( $self->parent->url );
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

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

# Fayland Lam, C<< <fayland at gmail.com> >>
