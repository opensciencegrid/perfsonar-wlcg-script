use strict;
use LWP::UserAgent; # from CPAN
use JSON qw( decode_json ); # from CPAN
use URI::Escape;

sub getAddress($){
    my ($address) = @_;

    $address =~ s/\s\s/ /g;

    my $encode = uri_escape($address);

#    print  " geocode  got address |$encode|\n";

    my $format = "json"; #can also to 'xml'

    my $geocodeapi = "http://maps.googleapis.com/maps/api/geocode/";

    my $url = $geocodeapi . $format . "?sensor=false&address=\"".$encode."\"";

#    print  "  URL:  $url\n";

#    my $json = get($url);
    my $ua =  LWP::UserAgent->new;
    $ua->timeout(5);
    my $response = $ua->get($url);
    my $d_json = "";
    if  ($response->is_success) {

#	print  "json:\n ".$response->decoded_content."\n";

	$d_json = decode_json( $response->decoded_content );

	my $formattedAddress = $d_json->{results}->[0]->{formatted_address};

	return ($formattedAddress);
    }  else {
	die  $response->status_line;
    }
}
1;
