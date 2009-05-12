package Net::Google::Code::Wiki::Comment;

use Moose;
use Params::Validate qw(:all);

has 'content' => (
    isa => 'Str',
    is  => 'rw',
);

has 'author' => (
    isa => 'Str',
    is  => 'rw',
);

has 'date' => (
    isa => 'Str',
    is  => 'rw',
);

sub parse {
    my $self = shift;
    my $html = shift;

    my $element;
    if ( blessed $html ) {
        $element = $html;
    }
    else {
        require HTML::TreeBuilder;
        my $element = HTML::TreeBuilder->new;
        $element->parse_content( $html );
        $element->elementify;
    }

    my $author =
      $element->look_down( class => 'author' )->find_by_tag_name('a')->as_text;
    my $date = $element->look_down( class => 'date' )->attr('title');
    my $content = $element->look_down( class => 'commentcontent' )->as_text;
    $content =~ s/\s+$//; # remove trailing spaces

    $self->author( $author ) if $author;
    $self->date( $date ) if $date;
    $self->content( $content ) if $content;
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::Google::Code::Wiki::Comment - Google Code Wiki Comment

=head1 INTERFACE

=over 4

=item parse( HTML::Element or html segment string )

=back

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
