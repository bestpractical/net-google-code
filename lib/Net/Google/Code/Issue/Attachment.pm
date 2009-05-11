package Net::Google::Code::Issue::Attachment;
use Moose;
with 'Net::Google::Code::Role';

has name    => ( isa => 'Str', is => 'rw' );
has url     => ( isa => 'Str', is => 'rw' );
has size    => ( isa => 'Str', is => 'rw' );

=head2 parse
there're 2 trs that represent an attachment like the following:

 <tr><td rowspan="2" width="24"><a href="http://chromium.googlecode.com/issues/attachment?aid=-1323983749556004507&amp;name=proxy_settings.png" target="new"><img width="16" height="16" src="/hosting/images/generic.gif" border="0" ></a></td>
 <td><b>proxy_settings.png</b></td></tr>
 <tr><td>14.3 KB
  
 <a href="http://chromium.googlecode.com/issues/attachment?aid=-1323983749556004507&amp;name=proxy_settings.png">Download</a></td></tr>

=cut

sub parse {
    my $self = shift;
    my $tr1  = shift;
    my $tr2  = shift;
    my $b    = $tr1->find_by_tag_name('b');    # name lives here
    if ($b) {
        my $name = $b->content_array_ref->[0];
        $name =~ s/^\s+//;
        $name =~ s/\s+$//;
        $self->name($name);
    }

    my $td = $tr2->find_by_tag_name('td');
    if ($td) {
        my $size = $td->content_array_ref->[0];
        $size =~ s/^\s+//;
        $size =~ s/\s+$//;
        $self->size($size);

        $self->url( $td->find_by_tag_name('a')->attr_get_i('href') );
    }

    return 1;
}

sub content {
    my $self = shift;
    return $self->fetch( $self->url );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Net::Google::Code::Issue::Attachment

=head1 DESCRIPTION

This class represents a single attachment for an issue.

=head1 INTERFACE

=head2 name

=head2 content

=head2 size

=head2 url

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

