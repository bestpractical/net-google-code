package Net::Google::Code::Issue::Attachment;
use Any::Moose;
with 'Net::Google::Code::Role::Fetchable', 'Net::Google::Code::Role::HTMLTree';
use Scalar::Util qw/blessed/;
use MIME::Types;
use File::MMagic;

has 'name'         => ( isa => 'Str', is => 'rw' );
has 'url'          => ( isa => 'Str', is => 'rw' );
has 'size'         => ( isa => 'Str', is => 'rw' );
has 'id'           => ( isa => 'Int', is => 'rw' );
has content => (
    isa     => 'Str',
    is      => 'rw',
    lazy    => 1,
    default => sub { ($_[0]->_load)[0] },
);

has content_type => (
    isa     => 'Str',
    is      => 'rw',
    lazy    => 1,
    default => sub { ($_[0]->_load)[1] },
);

sub parse {
    my $self = shift;
    my $html = shift;

    my ( $tr1, $tr2 );

    if ( blessed $html ) {
        ( $tr1, $tr2 ) = $html->find_by_tag_name( 'tr' );
    }
    elsif ( ref $html eq 'ARRAY' ) {
        ( $tr1, $tr2 ) = @$html;
    }
    else {
        my $tree = $self->html_tree( html => $html );
        ( $tr1, $tr2 ) = $tree->find_by_tag_name( 'tr' );
    }

    my $b    = $tr1->find_by_tag_name('b');    # name lives here
    if ($b) {
        my $name = $b->content_array_ref->[0];
        $name =~ s/^\s+//;
        $name =~ s/\s+$//;
        $self->name($name);

        # google code doesn't parse download's content type at all, we need to
        # figure it out by ourselves
        my $content_type = $self->_mime_type;
        if ( $content_type ) {
            $self->content_type( $content_type );
        }
    }

    my $td = $tr2->find_by_tag_name('td');
    if ($td) {
        my $size = $td->content_array_ref->[0];
        $size =~ s/^\s+//;
        $size =~ s/\s+$//;
        $self->size($size);

        $self->url( $td->find_by_tag_name('a')->attr('href') );
        if ( $self->url =~ /aid=([-\d]+)/ ) {
            $self->id( $1 );
        }
    }

    return 1;
}

sub parse_attachments {
    my $self    = shift;
    my $element = shift;
    $element = $self->html_tree( html => $element ) unless blessed $element;

    my @attachments;

    my @items = $element->find_by_tag_name('tr');
    while ( scalar @items ) {
        my $tr1 = shift @items;
        my $tr2 = shift @items;
        my $a   = Net::Google::Code::Issue::Attachment->new;

        if ( $a->parse( [ $tr1, $tr2 ] ) ) {
            push @attachments, $a;
        }
    }
    return @attachments;
}

sub _load {
    my $self    = shift;
    my $content = $self->fetch( $self->url );

    # in case MIME::Types failed to get, let File::MMagic rescue!
    my $content_type =
         $self->_mime_type
      || File::MMagic->new->checktype_contents($content)
      || 'application/octet-stream';
    $self->content( $content );
    $self->content_type( $content_type );
    return $content, $content_type;
}

sub _mime_type {
    my $self      = shift;
    my $mime_type = MIME::Types->new->mimeTypeOf( $self->name );
    return $mime_type ? $mime_type->type : undef;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Net::Google::Code::Issue::Attachment - Issue's Attachment

=head1 DESCRIPTION

This class represents a single attachment for an issue or an issue's comment.

=head1 INTERFACE

=over 4

=item parse( HTML::Element or [ HTML::Element, HTML::Element ] or html segment string )

there're 2 trs that represent an attachment like the following:

 <tr><td rowspan="2" width="24"><a href="http://chromium.googlecode.com/issues/attachment?aid=-1323983749556004507&amp;name=proxy_settings.png" target="new"><img width="16" height="16" src="/hosting/images/generic.gif" border="0" ></a></td>
 <td><b>proxy_settings.png</b></td></tr>
 <tr><td>14.3 KB
  
 <a href="http://chromium.googlecode.com/issues/attachment?aid=-1323983749556004507&amp;name=proxy_settings.png">Download</a></td></tr>

=cut

=item parse_attachments( HTML::Element or html segment string )

given the <div class="attachments">...</div> or its equivalent HTML::Element
object, return a list of Net::Google::Code::Attachment objects.

=item name

=item content

=item size

=item url

=item id

=item content

=item content_type


=back

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

