package Net::Google::Code::Role::Pageable;
use Any::Moose 'Role';
use Params::Validate ':all';
use WWW::Mechanize;
with 'Net::Google::Code::Role::Fetchable';
with 'Net::Google::Code::Role::HTMLTree';
use Scalar::Util qw/blessed/;
use Date::Manip;
use DateTime;
local $ENV{TZ} = 'GMT';


sub rows {
    my $self = shift;
    my %args = validate(
        @_,
        {
            html  => { type => SCALAR | OBJECT },
            limit => {
                type     => SCALAR | UNDEF,
                optional => 1,
            },
            updated_after => {
                type => SCALAR | OBJECT | UNDEF,
                optional => 1,
            },
        }
    );

    $args{limit} ||= 999_999_999; # the impossible huge limit
    my $tree = $args{html};
    $tree = $self->html_tree( html => $tree ) unless blessed $tree;

    my $updated_after = $args{updated_after};

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
    return unless $pagination;

    if ( my ( $start, $end, $total ) =
        $pagination->as_text =~ /(\d+)\s+-\s+(\d+)\s+of\s+(\d+)/ )
    {
        # all the rows in a page
        my @all_rows = $self->_rows(
            html         => $tree,
            titles       => \@titles,
            label_column => $label_column,
          );
        my $found_number = scalar @all_rows;
        my $max_discarded = 0;

        my $filter = sub {
            return 1 unless $args{updated_after};

            my $row = shift;

            if ( $row->{modified} ) {
                my $epoch = UnixDate( $row->{modified}, '%o' );
                if ( $epoch < $args{updated_after} ) {
                    $max_discarded = $row->{id} if $max_discarded < $row->{id};
                    return;
                }
                else {
                    return 1;
                }
            }
            elsif ( $row->{id} < $max_discarded ) {
   # no modified, means there is no comment, the updated date is the created
   # since the id is less than the max discarded id, it's safe to discard it too
                return;
            }
            else {
                return 1;
            }
        };

        push @rows, grep { $filter->($_) } @all_rows;

        $total = $args{limit} if $args{limit} < $total;
        while ( $found_number < $total ) {

            if ( $self->mech->follow_link( text_regex => qr/Next\s+/ ) ) {
                if ( $self->mech->response->is_success ) {
                    my @all_rows = $self->_rows(
                        html         => $self->mech->content,
                        titles       => \@titles,
                        label_column => $label_column,
                    );
                    $found_number += @all_rows;

                    push @rows, grep { $filter->($_) } @all_rows;
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
            next unless $column =~ /[-\w]/; # skip the '›' thing or alike

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

no Any::Moose;
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


