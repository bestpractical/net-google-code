package Net::Google::Code::Issue;
use Moose;
use Params::Validate qw(:all);
with 'Net::Google::Code::Role::Fetchable', 'Net::Google::Code::Role::URL',
     'Net::Google::Code::Role::HTMLTree',
     'Net::Google::Code::Role::Authentication';
use Net::Google::Code::Issue::Comment;
use Net::Google::Code::Issue::Attachment;
use Scalar::Util qw/blessed/;

has 'project' => (
    isa      => 'Str',
    is       => 'rw',
);

has 'id' => (
    isa      => 'Int',
    is       => 'rw',
);

has 'state' => (
    isa     => 'HashRef',
    is      => 'rw',
    default => sub { {} },
);

has 'labels' => (
    isa     => 'ArrayRef',
    is      => 'rw',
    default => sub { [] },
);

has 'comments' => (
    isa     => 'ArrayRef[Net::Google::Code::Issue::Comment]',
    is      => 'rw',
    default => sub { [] },
);

has 'attachments' => (
    isa     => 'ArrayRef[Net::Google::Code::Issue::Attachment]',
    is      => 'rw',
    default => sub { [] },
);

our @PROPS = qw(status owner closed cc summary reporter description);

for my $prop (@PROPS) {
    no strict 'refs';    ## no critic
    *{ "Net::Google::Code::Issue::" . $prop } = sub { shift->state->{$prop} };
}

sub load {
    my $self = shift;
    my $id = shift || $self->id;
    die "current object doesn't have id and load() is not passed an id either"
      unless $id;
    my $content = $self->fetch( $self->base_url . "issues/detail?id=" . $id );
    $self->id( $id );
    return $self->parse($content);
}

sub parse {
    my $self    = shift;
    my $tree    = shift;

    $tree = $self->html_tree( html => $tree ) unless blessed $tree;

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

    my $att_tag = $tree->look_down( class => 'attachments' );
    my @attachments;
    @attachments =
      Net::Google::Code::Issue::Attachment->parse_attachments($att_tag)
      if $att_tag;
    $self->attachments( \@attachments );

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

            if ( $href =~ /list\?q=label:(.+)/ ) {
                $self->labels( [ @{$self->labels}, $1 ] );
            }
        }
    }

    # extract comments
    my @comments_tag = $tree->look_down( class => 'vt issuecomment' );
    my @comments;
    for my $tag (@comments_tag) {
        next unless $tag->look_down( class => 'author' );
        my $comment =
          Net::Google::Code::Issue::Comment->new( project => $self->project );
        $comment->parse($tag);
        push @comments, $comment;
    }
    $self->comments( \@comments );

}

sub create {
    my $self = shift;
    my %args = validate(
        @_,
        {
            labels => { type => ARRAYREF, optional => 1 },
            files  => { type => ARRAYREF, optional => 1 },
            map { $_ => { type => SCALAR, optional => 1 } }
              qw/comment summary status owner cc/,
        }
    );

    $self->sign_in;
    $self->fetch( $self->base_url . 'issues/entry' );

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
    # leave labels alone unless there're labels.
    $self->mech->field( 'label', $args{labels} ) if $args{labels};

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

    my ( $contains, $id ) = $self->html_tree_contains(
        html      => $self->mech->content,
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
            labels => { type => ARRAYREF, optional => 1 },
            files  => { type => ARRAYREF, optional => 1 },
            map { $_ => { type => SCALAR, optional => 1 } }
              qw/comment summary status owner merge_into cc blocked_on/,
        }
    );

    $self->sign_in;
    $self->fetch( $self->base_url . 'issues/detail?id=' . $self->id );

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

    # leave labels alone unless there're labels.
    $self->mech->field( 'label', $args{labels} ) if $args{labels};
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
        $self->html_tree_contains(
            html      => $self->mech->content,
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

=item project

=item id

=item status

=item owner 

=item reporter

=item closed

=item cc

=item summary

=item create
comment, summary, status, owner, cc, labels, files.

=item update
comment, summary, status, owner, merge_into, cc, labels, blocked_on, files.

=item description

=item labels

=item comments

=item attachments

=back

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
