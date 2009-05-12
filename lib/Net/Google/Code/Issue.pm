package Net::Google::Code::Issue;
use Moose;
use Params::Validate qw(:all);
with 'Net::Google::Code::Role';
use Net::Google::Code::Issue::Comment;

has state => (
    isa     => 'HashRef',
    is      => 'rw',
    default => sub { {} },
);

has labels => (
    isa     => 'HashRef',
    is      => 'rw',
    default => sub { {} },
);

has comments => (
    isa     => 'ArrayRef[Net::Google::Code::Comment]',
    is      => 'rw',
    default => sub { [] },
);

has attachments => (
    isa     => 'ArrayRef[Net::Google::CodeTicketAttachment]',
    is      => 'rw',
    default => sub { [] },
);

our @PROPS = qw(id status owner closed cc summary reporter description);

for my $prop (@PROPS) {
    no strict 'refs';    ## no critic
    *{ "Net::Google::Code::Issue::" . $prop } = sub { shift->state->{$prop} };
}

sub load {
    my $self = shift;
    my ($id) = validate_pos( @_, { type => SCALAR } );
    $self->state->{id} = $id;
    my $content = $self->fetch( $self->base_url . "issues/detail?id=" . $id );
    $self->parse($content);
    return $id;
}

sub parse {
    my $self    = shift;
    my $content = shift;

    require HTML::TreeBuilder;
    my $tree = HTML::TreeBuilder->new;
    $tree->parse_content($content);
    $tree->elementify;

    # extract summary
    my ($summary) = $tree->look_down( class => 'h3' );
    $self->state->{summary} = $summary->content_array_ref->[0];

    # extract reporter and description
    my $description = $tree->look_down( class => 'vt issuedescription' );
    $self->state->{reporter} =
      $description->look_down( class => "author" )->content_array_ref->[1]
      ->content_array_ref->[0];
    my $text = $description->find_by_tag_name('pre')->as_text;
    $text =~ s/^\s+//;
    $text =~ s/\s+$/\n/;
    $text =~ s/\r\n/\n/g;
    $self->state->{description} = $text;

    my $attachments = $description->look_down( class => 'attachments' );
    if ($attachments) {
        my @items = $attachments->find_by_tag_name('tr');
        require Net::Google::Code::Issue::Attachment;
        while ( scalar @items ) {
            my $tr1 = shift @items;
            my $tr2 = shift @items;
            my $a =
              Net::Google::Code::Issue::Attachment->new(
                project => $self->project );

            if ( $a->parse( $tr1, $tr2 ) ) {
                push @{ $self->attachments }, $a;
            }
        }
    }

    my ($meta) = $tree->look_down( id => 'issuemeta' );
    my @meta = $meta->find_by_tag_name('tr');
    for my $meta (@meta) {

        my ( $key, $value );
        if ( my $k = $meta->find_by_tag_name('th') ) {
            my $v         = $meta->find_by_tag_name('td');
            my $k_content = $k->content_array_ref->[0];
            while ( ref $k_content ) {
                $k_content = $k_content->content_array_ref->[0];
            }
            $key = $k_content;    # $key is like 'Status:#'
            $key =~ s/:.$//;      # s/:#$// doesn't work, no idea why

            if ($v) {
                my $v_content = $v->content_array_ref->[0];
                while ( ref $v_content ) {
                    $v_content = $v_content->content_array_ref->[0];
                }
                $value = $v_content;
                $value =~ s/^\s+//;
                $value =~ s/\s+$//;
            }
            $self->state->{ lc $key } = $value;
        }
        else {
            my $href = $meta->find_by_tag_name('a')->attr_get_i('href');

# from issue tracking faq:
# The prefix before the first dash is the key, and the part after it is the value.
            if ( $href =~ /list\?q=label:([^-]+?)-(.+)/ ) {
                $self->labels->{$1} = $2;
            }
            elsif ( $href =~ /list\?q=label:([^-]+)$/ ) {
                $self->labels->{$1} = undef;
            }
            else {
                warn "can't parse label from $href";
            }
        }
    }

    # extract comments
    my @comments = $tree->look_down( class => 'vt issuecomment' );
    pop @comments;    # last one is for adding comment
    for my $comment (@comments) {
        my $object =
          Net::Google::Code::Issue::Comment->new( project => $self->project );
        $object->parse($comment);
        push @{ $self->comments }, $object;
    }

}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Net::Google::Code::Issue - Google Code Issue

=head1 SYNOPSIS

    use Net::Google::Code::Issue;
    
    my $issue = Net::Google::Code::Issue->new( project => 'net-google-code' );
    $issue->load(42);

=head1 DESCRIPTION

=head1 INTERFACE

=over 4

=item load

=item parse

=item id

=item status

=item owner 

=item reporter

=item closed

=item cc

=item summary

=item description

=back

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
