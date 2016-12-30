package MetaCpan;

use strict;
use warnings;
use lib '../external/lib';
use Data::Dumper;

use LWP::UserAgent;
use JSON::XS;
use Exporter qw| import |;
use Alfred;

our @EXPORT_OK = qw| search |;

our $link = 'https://metacpan.org/search/autocomplete?q=';
our $ua   = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0 });

sub search {
    my $query = shift || undef;
   
    return undef unless $query;

    my $response = $ua->get( $link . $query );
    my $json =  decode_json $response->content;

    if ( $response->is_success ) {
        my $alfred = Alfred->new();
        warn Dumper $json;
        foreach my $item ( @{ $json->{suggestions} } ) {
            $alfred->add({
                autocomplete => $item->{value},
                arg          => $item->{value},
                title        => $item->{value},
                #subtitle     => 'release: ' . $item->{release},
                icon         => 'metacpan.png',
            });
        }
        return $alfred->xml;
    }

    return undef;
}

1;

