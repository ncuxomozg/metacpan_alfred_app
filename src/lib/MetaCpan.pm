package MetaCpan;

use strict;
use warnings;
use lib '../external/lib';

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
        foreach my $item ( @{ $json } ) {
            $alfred->add({
                autocomplete => $item->{documentation},
                arg          => $item->{documentation},
                title        => $item->{documentation},
                subtitle     => 'release: ' . $item->{release},
                icon         => 'metacpan.png',
            });
        }
        return $alfred->xml;
    }

    return undef;
}

1;

