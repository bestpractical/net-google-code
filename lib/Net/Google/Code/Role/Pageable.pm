package Net::Google::Code::Role::Pageable;
use Moose::Role;
use Params::Validate ':all';
use WWW::Mechanize;
with 'Net::Google::Code::Role::Fetchable';
use Scalar::Util qw/blessed/;
no Moose::Role;

sub first_columns {
    my $self = shift;
    my $html = shift;
    my $tree;
    if ( blessed $html ) {
        $tree = $html;
    }
    else {
        require HTML::TreeBuilder;
        $tree = HTML::TreeBuilder->new;
        $tree->parse_content($html);
        $tree->elementify;
    }

    my @columns;

    my $pagination = $tree->look_down( class => 'pagination' );
    if ( my ( $start, $end, $total ) =
        $pagination->as_text =~ /(\d+)\s+-\s+(\d+)\s+of\s+(\d+)/ )
    {
        push @columns, $self->_first_columns($tree);

        while ( scalar @columns < $total ) {
            if ( $self->mech->follow_link( text_regex => qr/Next\s+/ ) ) {
                if ( $self->mech->response->is_success ) {
                    push @columns,
                      $self->_first_columns( $self->mech->content );
                }
                else {
                    die "failed to follow 'Next' link";
                }
            }
            else {
                warn "didn't find enough rows";
                last;
            }
        }
    }
    return @columns;
}

sub _first_columns {
    my $self = shift;
    my $html = shift;
    my $tree;
    if ( blessed $html ) {
        $tree = $html;
    }
    else {
        require HTML::TreeBuilder;
        $tree = HTML::TreeBuilder->new;
        $tree->parse_content($html);
        $tree->elementify;
    }

    my @columns;
    my @tags = $tree->look_down( class => 'vt id col_0' );
    for my $tag (@tags) {
        my $column = $tag->as_text;
        $column =~ s/^\s+//;
        $column =~ s/\s+$//;
        push @columns, $column;
    }
    return @columns;
}

1;

__END__

=head1 NAME

Net::Google::Code::Role::Pageable - Pageable Role


=head1 DESCRIPTION

=head1 INTERFACE

=over 4

=item first_columns

=back

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


