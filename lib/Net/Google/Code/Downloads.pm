package Net::Google::Code::Downloads;

use Moose;
use XML::Atom::Feed;
use URI;
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
	my $feed_url   = "http://code.google.com/feeds/p/$project/downloads/basic";
	
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

sub entry {
	my $self = shift;
	
	my ($filename) = validate_pos( @_, { type => SCALAR } );
	
	# http://code.google.com/p/net-google-code/downloads/detail?name=Net-Google-Code-0.01.tar.gz
	
	my $connection = $self->connection;
	my $project    = $connection->project;
	
	my $url = "http://code.google.com/p/$project/downloads/detail?name=$filename";
	my $content = $connection->_fetch( $url );
	
	require HTML::TreeBuilder;
    my $tree = HTML::TreeBuilder->new;
    $tree->parse_content($content);
    $tree->elementify;
    
    my $entry;
    ($entry->{upload_time}) = $tree->look_down(class => 'date')->attr('title');
    
    # uploader, download count etc.
    my ($meta) = $tree->look_down( id => 'issuemeta' );
    my @meta = $meta->find_by_tag_name('tr');
    for my $meta (@meta) {

        my ( $key, $value );
        if ( my $k = $meta->find_by_tag_name('th') ) {
            my $v         = $meta->find_by_tag_name('td');
            my $k_content = $k->content_array_ref->[0];
            while ( ref $k_content ) {
                $k_content = $k_content->content_array_ref->[0];
            }
            $key = $k_content;    # $key is like 'Status:#'
            
            if ($v) {
                my $v_content = $v->content_array_ref->[0];
                while ( ref $v_content ) {
                    $v_content = $v_content->content_array_ref->[0];
                }
                $value = $v_content;
                $value =~ s/^\s+//;
                $value =~ s/\s+$//;
            }
        }
        
        if ( $key =~ /Upload/ and $key =~ /by/ ) {
        	$entry->{uploader} = $value;
        } elsif ( $key =~ /Downloads/ ) {
        	$entry->{download_count} = $value;
        }
    }
    
    # file size etc.
    ($meta) = $tree->look_down( class => 'vt issuedescription' );
    my $meta2 = $meta->find_by_attribute('class', 'box-inner');
    my $meta3 = $meta->find_by_tag_name('span');
    $entry->{download_url} = $meta2->content_array_ref->[0]->attr('href');
    my $file_size = $meta2->content_array_ref->[3];
    $file_size =~ s/(^\s+\D*|\s+$)//g;
    $entry->{file_size} = $file_size;
    my $file_SHA1_text = $meta3->content_array_ref->[0];
    my ( $file_SHA1 ) = ( $file_SHA1_text =~ /^SHA1 Checksum:\s+(\S+)$/ );
    $entry->{file_SHA1} = $file_SHA1;

    return $entry;
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
    foreach my $e ( @entries ) {
        my $entry = $download->entry( $e->{filename} );
        print Dumper(\$entry);
    }

=head1 DESCRIPTION

get Downloads details from Google Code Project

=head1 METHODS

=head2 all_entries

Get all download entries from the Atom feed

=head2 entry

    my $entry = $download->entry( $entries[0]->{filename} ); # 'Net-Google-Code-0.01.tar.gz'

get an entry details, sample $entry:

    {
        'uploader' => 'sunnavy',
        'file_size' => '37.4 KB',
        'download_url' => 'http://net-google-code.googlecode.com/files/Net-Google-Code-0.01.tr.gz',
        'file_SHA1' => '5073de2276f916cf5d74d7abfd78a463e15674a1',
        'upload_time' => 'Tue Jan  6 00:16:06 2009',
        'download_count' => '6'
    };

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright 2008-2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

