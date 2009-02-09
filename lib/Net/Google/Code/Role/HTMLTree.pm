package Net::Google::Code::Role::HTMLTree;
use Moose::Role;
use HTML::TreeBuilder;

with 'Net::Google::Code::Role::Connectable';

use HTML::TreeBuilder;
use Params::Validate qw(:all);

has 'html_tree' => (
    isa     => 'HTML::TreeBuilder',
    is      => 'rw',
    default => sub {
        return HTML::TreeBuilder->new;
    },
);

sub html_contains {
    my $self = shift;
    my %args = validate(
        @_,
        {
            look_down => { type => ARRAYREF, optional => 1 },

            # SCALARREF is for the regex
            as_text => { type => SCALAR | SCALARREF },
        }
    );

    my $tree = $self->html_tree;
    $tree = $tree->parse( $self->mech->content );
    $tree->elementify;
    my $part = $tree;
    if ( $args{look_down} ) {
        ($part) = $tree->look_down( @{ $args{look_down} } );
    }
    open my $fh, '>', '/tmp/t.html';
    print $fh $self->mech->content;
    close $fh;

    return unless $part;

    return 1
      if ref $args{as_text} eq 'Regexp' && $part->as_text =~ $args{as_text}
          || $part->as_text eq $args{as_text};
    return;
}

no Moose::Role;

1;

__END__

=head1 NAME

Net::Google::Code::Role::HTMLTree - 

=head1 DESCRIPTION

=head1 INTERFACE


=head2 html_contains

a help method to help test if the current content contains some stuff, args are:
look_down => [ look_down's args ]
as_text => qr/foo/

look_down is used to limit the area,
as_text's value can be regex or string 

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


