package Net::Google::Code;

use Moose;
with 'Net::Google::Code::Role';

our $VERSION = '0.03';

has 'labels' => (
    isa => 'ArrayRef',
    is  => 'rw',
);

has 'owners' => (
    isa => 'ArrayRef',
    is  => 'rw',
);

has 'members' => (
    isa => 'ArrayRef',
    is  => 'rw',
);

has 'summary' => (
    isa => 'Str',
    is  => 'rw',
);

has 'description' => (
    isa => 'Str',
    is  => 'rw',
);

=head2 load

load project's home page, and parse its metadata

=cut

sub load {
    my $self = shift;
    my $content = $self->fetch( $self->base_url );
    return $self->parse( $content );
}

=head2 parse

acturally do the parse job, for load();

=cut

sub parse {
    my $self    = shift;
    my $content = shift;
    require HTML::TreeBuilder;
    my $tree = HTML::TreeBuilder->new;
    $tree->parse_content($content);
    $tree->elementify;

    my $summary =
      $tree->look_down( id => 'psum' )->find_by_tag_name('a')->content_array_ref->[0];
    $self->summary($summary) if $summary;

    my $description =
      $tree->look_down( id => 'wikicontent' )->content_array_ref->[0]->as_text;
    $self->description($description) if $description;

    my @members;
    my @members_tags =
      $tree->look_down( id => 'members' )->find_by_tag_name('a');
    for my $tag (@members_tags) {
        push @members, $tag->content_array_ref->[0];
    }
    $self->members( \@members ) if @members;

    my @owners;
    my @owners_tags = $tree->look_down( id => 'owners' )->find_by_tag_name('a');
    for my $tag (@owners_tags) {
        push @owners, $tag->content_array_ref->[0];
    }
    $self->owners( \@owners ) if @owners;

    my @labels;
    my @labels_tags = $tree->look_down( href => qr/q\=label\:/ );
    for my $tag (@labels_tags) {
        push @labels, $tag->content_array_ref->[0];
    }
    $self->labels( \@labels ) if @labels;

}

sub issue {
    my $self = shift;
    require Net::Google::Code::Issue;
    return Net::Google::Code::Issue->new(
        project => $self->project,
        @_
    );
}

sub downloads {

    my $self = shift;
    require Net::Google::Code::Downloads;
    return Net::Google::Code::Downloads->new(
        project => $self->project,
        @_
    );
}

sub wiki {

    my $self = shift;
    require Net::Google::Code::Wiki;
    return Net::Google::Code::Wiki->new(
        project => $self->project,
        @_
    );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::Google::Code - a simple client library for google code

=head1 SYNOPSIS

    use Net::Google::Code;
    
    my $project = Net::Google::Code->new( project => 'net-google-code' );
    $project->load; # load its metadata, e.g. summary, owners, members, etc.
    
    print join(', ', @{ $project->owners } );
    
    $project->issue;
    $project->downloads;
    $project->wiki;

=head1 DESCRIPTION

Net::Google::Code is a simple client library for projects hosted in Google Code.

Currently, it focuses on the basic read functionality for that is provided.

=head1 ATTRIBUTES

=over 4

=item project

the project name

=item base_url

the project homepage

=item base_svn_url

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

=back

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
