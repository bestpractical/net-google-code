package Net::Google::Code::Role::Pageable;
use Moose::Role;
use Params::Validate ':all';
use WWW::Mechanize;
with 'Net::Google::Code::Role::Fetchable', 'Net::Google::Code::Role::HTMLTree';
use Scalar::Util qw/blessed/;
no Moose::Role;

sub rows {
    my $self = shift;
    my %args = validate(
        @_,
        {
            html  => { type => SCALAR | OBJECT },
            limit => {
                type     => SCALAR,
                optional => 1,
            },
        }
    );
    $args{limit} ||= 999_999_999; # the impossible huge limit
    my $tree = $args{html};
    $tree = $self->html_tree( html => $tree ) unless blessed $tree;

    # assuming there's at most 20 columns
    my @titles;
    my $label_column;
    for my $num ( 0 .. 20 ) {
        my $title_tag = $tree->look_down( class => "col_$num" );
        if ( $title_tag ) {
            my $title = $title_tag->as_text;
            if ( $title eq "\x{a0}" ) {
                $title_tag = ($tree->look_down( class => "col_$num" ))[1];
                $title = $title_tag->as_text;
            }

            if ( $title =~ /(\w+)/ ) {
                push @titles, lc $1;

                if ( $title =~ /label/i ) {
                    $label_column = $num;
                }
            }
        }
        else {
            last;
        }
    }

    die "no idea what the column spec is" unless @titles;

    my @rows;

    my $pagination = $tree->look_down( class => 'pagination' );
    if ( my ( $start, $end, $total ) =
        $pagination->as_text =~ /(\d+)\s+-\s+(\d+)\s+of\s+(\d+)/ )
    {
        push @rows,
          $self->_rows(
            html         => $tree,
            titles       => \@titles,
            label_column => $label_column,
          );

        $total = $args{limit} if $args{limit} < $total;
        while ( scalar @rows < $total ) {

            if ( $self->mech->follow_link( text_regex => qr/Next\s+/ ) ) {
                if ( $self->mech->response->is_success ) {
                    push @rows,
                      $self->_rows(
                        html         => $self->mech->content,
                        titles       => \@titles,
                        label_column => $label_column,
                      );
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
    if ( scalar @rows > $args{limit} ) {
        # this happens when limit is less than the 1st page's number 
        return @rows[0 .. $args{limit}-1];
    }
    else {
        return @rows;
    }
}

sub _rows {
    my $self = shift;
    my %args = validate(
        @_,
        {
            html         => { type => SCALAR | OBJECT },
            titles       => { type => ARRAYREF, },
            label_column => { optional => 1 },
        }
    );
    my $tree = $args{html};
    $tree = $self->html_tree( html => $tree ) unless blessed $tree;
    my @titles = @{$args{titles}};
    my $label_column = $args{label_column};

    my @columns;
    my @rows;

    for ( my $i = 0 ; $i < @titles ; $i++ ) {
        my @tags = $tree->look_down( class => qr/^vt (id )?col_$i/ );
        my $k = 0;
        for ( my $j = 0 ; $j < @tags ; $j++ ) {
            my $column = $tags[$j]->as_text;
            next if $column eq "\x{203a}"; # skip the '›' thing

            my @elements  = split /\x{a0}/, $column;
            for ( @elements ) {
                s/^\s+//;
                s/\s+$//;
            }
            $column = shift @elements;
            $column = '' if $column eq '----';

            if ( $i == 0 ) {
                push @rows, { $titles[0] => $column };
            }
            else {
                $rows[$k]{ $titles[$i] } = $column;
            }

            if ( $label_column && $i == $label_column ) {
                my @labels;
                if (@elements) {
                    @labels = split /\s+/, shift @elements;
                }
                $rows[$k]{labels} = \@labels if @labels;
            }
            $k++;
        }
    }
    return @rows;
}

1;

__END__

=head1 NAME

Net::Google::Code::Role::Pageable - Pageable Role


=head1 DESCRIPTION

=head1 INTERFACE

=over 4

=item rows

=back

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


