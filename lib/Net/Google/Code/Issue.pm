package Net::Google::Code::Issue;
use Moose;
use Params::Validate qw(:all);
with 'Net::Google::Code::Role';
use Net::Google::Code::IssueComment;

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
    $self->html( $self->fetch( "issues/detail?id=" . $id ) );
    $self->parse;
    return $id;
}

sub parse {
    my $self    = shift;

    my $tree = $self->html_tree( content => $self->html );

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
        require Net::Google::Code::IssueAttachment;
        while ( scalar @items ) {
            my $tr1 = shift @items;
            my $tr2 = shift @items;
            my $a =
              Net::Google::Code::IssueAttachment->new(
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
          Net::Google::Code::IssueComment->new( project => $self->project );
        $object->parse($comment);
        push @{ $self->comments }, $object;
    }

}

sub create {
    my $self = shift;
    my %args = validate(
        @_,
        {
            labels => { type => HASHREF | ARRAYREF, optional => 1 },
            files  => { type => ARRAYREF, optional => 1 },
            map { $_ => { type => SCALAR, optional => 1 } }
              qw/comment summary status owner cc/,
        }
    );

    if ( ref $args{labels} eq 'HASH' ) {
        $args{labels} = [ $self->labels_array( labels => $args{labels} ) ];
    }

    $self->sign_in;
    $self->fetch( 'issues/entry' );

    if ( $args{files} ) {
# hack hack hack
# manually add file fields since we don't have them in page.
        my $html = $self->mech->content;
        for ( 1 .. @{$args{files}} ) {
            $html =~
s{(?<=id="attachmentareadeventry"></div>)}{<input name="file$_" type="file">};
        }
        $self->mech->update_html( $html );
    }

    $self->mech->form_with_fields( 'comment', 'summary' );
    $self->mech->field( 'label', $args{labels} );
    if ( $args{files} ) {
        for ( my $i = 0; $i < scalar @{ $args{files} }; $i++ ) {
            $self->mech->field( 'file' . ($i + 1), $args{files}[$i] );
        }
    }

    $self->mech->submit_form(
        fields => {
            map { $_ => $args{$_} }
              grep { exists $args{$_} }
              qw/comment summary status owner cc/
        }
    );

    my ( $contains, $id ) = $self->html_contains(
        look_down => [ class => 'notice' ],
        as_text   => qr/Issue\s+(\d+)/i,
    );

    if ( $contains )
    {
        $self->load( $id );
        return $id;
    }
    else {
        warn 'create issue failed';
        return;
    }
}

sub update {
    my $self = shift;
    my %args = validate(
        @_,
        {
            labels => { type => HASHREF | ARRAYREF, optional => 1 },
            files  => { type => ARRAYREF, optional => 1 },
            map { $_ => { type => SCALAR, optional => 1 } }
              qw/comment summary status owner merge_into cc blocked_on/,
        }
    );

    if ( ref $args{labels} eq 'HASH' ) {
        $args{labels} = [ $self->labels_array( labels => $args{labels} ) ];
    }

    $self->sign_in;
    $self->fetch( 'issues/detail?id=' . $self->id );

    if ( $args{files} ) {
# hack hack hack
# manually add file fields since we don't have them in page.
        my $html = $self->mech->content;
        for ( 1 .. @{$args{files}} ) {
            $html =~
s{(?<=id="attachmentarea"></div>)}{<input name="file$_" type="file">};
        }
        $self->mech->update_html( $html );
    }

    $self->mech->form_with_fields( 'comment', 'summary' );
    $self->mech->field( 'label', $args{labels} );
    if ( $args{files} ) {
        for ( my $i = 0; $i < scalar @{ $args{files} }; $i++ ) {
            $self->mech->field( 'file' . ($i + 1), $args{files}[$i] );
        }
    }

    $self->mech->submit_form(
        fields => {
            map { $_ => $args{$_} }
              grep { exists $args{$_} }
              qw/comment summary status owner merge_into cc blocked_on/
        }
    );

    if (
        $self->html_contains(
            look_down => [ class => 'notice' ],
            as_text   => qr/has been updated/,
        )
      )
    {
        $self->load( $self->id ); # maybe this is too much?
        return 1;
    }
    else {
        warn 'update failed';
        return;
    }
}


sub labels_array {
    my $self = shift;
    my %args = validate( @_, { labels => { type => HASHREF, optional => 1 } } );
    my $labels = $args{labels} || $self->labels;

    if ( keys %$labels ) {
        return map { $_ . '-' . ( $labels->{$_} || '' ) } sort keys %$labels;
    }
    return;
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

=head2 load

=head2 parse

=head2 id

=head2 status

=head2 owner 

=head2 reporter

=head2 closed

=head2 cc

=head2 summary

=head2 description

=head2 create
comment, summary, status, owner, cc, labels, files.

Caveat: 'files' field doesn't work right now, please don't use it.

=head2 update
comment, summary, status, owner, merge_into, cc, labels, blocked_on, files.

Caveat: 'files' field doesn't work right now, please don't use it.

=head2 labels_array
convert hashref to array.
accept labels as arg, e.g. lables_array( labels => { label_hash } )
if there is no labels arg, use the $self->labels

e.g. { Type => 'Defect', Priority => 'High' } to ( 'Type-Defect', 'Priority-High' )

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
