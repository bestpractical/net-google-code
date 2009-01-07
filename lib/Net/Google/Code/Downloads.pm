package Net::Google::Code::Downloads;

use Moose;
use XML::Atom::Feed;
use URI;
use Params::Validate qw(:all);

has connection => (
    isa => 'Net::Google::Code::Connection',
    is  => 'ro',
    required => 1,
);

sub all_entries {
	my $self = shift;
	
	my $connection = $self->connection;
	my $project    = $connection->project;
	my $feed_url   = "http://code.google.com//feeds/p/$project/downloads/basic";
	
	my $content = $connection->_fetch( $feed_url );
	my $feed = XML::Atom::Feed->new( \$content );
	my @fentries = $feed->entries;
	
	my @dentries;
	foreach my $entry (@fentries) {
		my $link   = $entry->link;
		my $title  = $entry->title;
		my $author = $entry->author;
		my ($dtitle, $dsize) = ( $title =~ /^\s*(.*?)\s+\((.*?)\)/ );
		
		push @dentries, {
			filename => $dtitle,
			author   => $author->name,
			size     => $dsize,
			link     => $link->href,
		}
	}
	
	return wantarray ? @dentries : \@dentries;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::Google::Code::Downloads - Google Code Downloads

=head1 SYNOPSIS

    use Net::Google::Code::Connection;
    my $connection = Net::Google::Code::Connection( project => 'net-google-code' );

    use Net::Google::Code::Downloads;
    my $download = Net::Google::Code::Downloads->new( connection => $connection );
    
    my @entries = $download->all_entries;


=head1 DESCRIPTION

get Downloads details from Google Code Project

=head1 METHODS

=head2 all_entries

Get all download entries from the Atom feed

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

