package MetaCpan;

use strict;
use warnings;

use LWP::UserAgent;
use JSON::XS;
use Exporter qw| import |;

our @EXPORT_OK = qw| search |;

our $link = 'https://metacpan.org/search/autocomplete?q=';
our $ua   = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0 });

sub search {
    my $query = shift || undef;
   
    return undef unless $query;

    my $response = $ua->get( $link . $query );

    my $json =  decode_json $response->content;
    return _to_xml( $json ) if ( $response->is_success ); 
    return undef;
}

sub _to_xml {
    my $data = shift;

    my $xml = q|<?xml version="1.0"?><items>|;
    foreach my $item ( @{ $data }) {
       $xml .= qq|
            <item autocomplete='$item->{documentation}' arg="$item->{documentation}">
                <title>$item->{documentation}</title>
                <subtitle>release: $item->{release}</subtitle>
                <icon>metacpan.png</icon>
            </item>
       |;
    }

    $xml .= q|</items></xml>|;
}

1;

