package Net::Google::Code::Wiki;

use Moose;
use Params::Validate qw(:all);

use Net::Google::Code::WikiEntry;

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
		if ( $line =~ /href\=\"(.*?)\.wiki\"\>\1\.wiki/ ) {
			push @entries, $1;
		}
	}
	
	return wantarray ? @entries : \@entries;
}

sub entry {
    my $self = shift;
    
    my ($wiki_item) = validate_pos( @_, { type => SCALAR } );
    
    return Net::Google::Code::WikiEntry->new( connection => $self->connection, name => $wiki_item );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::Google::Code::Wiki - Google Code Wiki

=head1 SYNOPSIS

    use Net::Google::Code;
    
    my $project = Net::Google::Code->new( project => 'net-google-code' );
    my $wiki = $project->wiki;
    
    my @entries = $wiki->all_entries;
    foreach my $item ( @entries ) {
        my $entry = $wiki->entry($item);
        print $entry->source, "\n";
    }
    
=head1 DESCRIPTION

get Wiki details from Google Code Project

=head1 METHODS

=head2 all_entries

get all entries (name ONLY) from wiki svn

=head2 entry

return a instance of L<Net::Google::Code::WikiEntry>

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

