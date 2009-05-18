package Net::Google::Code::Role::DateTime;
use Moose::Role;
use DateTime;

our %MONMAP = (
    Jan => 1,
    Feb => 2,
    Mar => 3,
    Apr => 4,
    May => 5,
    Jun => 6,
    Jul => 7,
    Aug => 8,
    Sep => 9,
    Oct => 10,
    Nov => 11,
    Dec => 12,
);

sub parse_datetime {
    my $self      = shift;
    my $base_date = shift;
    if (
        $base_date =~ /\w{3}\s+(\w+)\s+(\d+)\s+(\d\d):(\d\d):(\d\d)\s+(\d{4})/ )
    {
        my $mon = $1;
        my $dom = $2;
        my $h   = $3;
        my $m   = $4;
        my $s   = $5;
        my $y   = $6;
        my $dt  = DateTime->new(
            year   => $y,
            month  => $MONMAP{$mon},
            day    => $dom,
            hour   => $h,
            minute => $m,
            second => $s
        );
        return $dt;
    }
}

no Moose::Role;

1;

__END__

=head1 NAME

Net::Google::Code::Role::DateTime - DateTime Role

=head1 DESCRIPTION

=head1 INTERFACE

=head2 parse_datetime

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


