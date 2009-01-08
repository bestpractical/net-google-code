package Net::Google::Code::Wiki;

use Moose;
use Params::Validate qw(:all);

our $VERSION = '0.02';
our $AUTHORITY = 'cpan:FAYLAND';

has connection => (
    isa => 'Net::Google::Code::Connection',
    is  => 'ro',
    required => 1,
);

sub all_entries {
	my $self = shift;
	
	my $connection = $self->connection;
	my $project    = $connection->project;
	
	my $wiki_svn = "http://$project.googlecode.com/svn/wiki/";
	my $content = $connection->_fetch( $wiki_svn );
	
	# regex would be OK
	my @lines = split("\n", $content);
	my @entries;
	foreach my $line (@lines ) {
		# <li><a href="AUTHORS.wiki">AUTHORS.wiki</a></li>
		if ( $line =~ /href\="(.*?)\.wiki\"\>\1\.wiki/ ) {
			push @entries, $1;
		}
	}
	
	return wantarray ? @entries : \@entries;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::Google::Code::Wiki - Google Code Wiki

=head1 SYNOPSIS

    use Net::Google::Code::Connection;
    my $connection = Net::Google::Code::Connection( project => 'net-google-code' );

    use Net::Google::Code::Wiki;
    my $wiki = Net::Google::Code::Wiki->new( connection => $connection );
    
=head1 DESCRIPTION

get Wiki details from Google Code Project

=head1 METHODS

=head2 all_entries

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

