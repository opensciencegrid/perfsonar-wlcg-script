#!/usr/bin/perl
#
#
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use JSON qw( decode_json );
use Data::Dumper;
use strict;
use warnings;

require  "geocode.pl";
require  "geoaddress.pl";

my $member=$ARGV[0];

my $ua = new LWP::UserAgent;
$ua->timeout(7);  #  Wait  up  to  5  seconds
my $url =  "http://$member/toolkit";

my $request  =  new  HTTP::Request('GET',$url);
my $response =  $ua->request($request);
if  ($response->is_success)  {
    my $page =  $response->decoded_content;
   
    my $Country='';
    my $City =  '';
    my $State =  '';
    my $Location = '';
    my $FormattedAddress  = '';
    if  ($page  =~ /<td>City, State, Country<\/td><td>([^,]*), ([^,]*), ([^<]*)</)  {
	$City = $1;
	$State  =  $2;
        $Country  =  $3;
    } else {
	warn "Host $member is missing City, State Country!\n";
	# Try  get  "Host Location"  from  page
	if  ($page =~  /<td>Host Location<\/td><td>([^<]+)</) {
	    $Location =$1;
	    print  "Found  location  $Location\n";
	    $FormattedAddress = &getAddress($Location);   
	    print " Formatted_Address $FormattedAddress\n";
	    my @add = split(/,/,$FormattedAddress);
	    $Country = $add[$#add];
	    $State = $add[$#add-1];
	    $City = $add[$#add-2];
	    print  "  Guess  City:$City  State:$State Country:$Country\n";
	}  else  {
	    print  "No known location for $member\n";
	}
    }
    my $Latitude = '';
    my $Longitude = '';
    if  ($page =~ /<td>Latitude,Longitude<\/td><td>([\.\d]+),([-\.\d]+)/)  {
	$Latitude = $1;
	$Longitude = $2;
    }  else  {
	warn "Host $member is missing latitude/longitude\n";
	if ($Country ne '') {
	    print  "Trying  geolocation...\n";
	    my $Address="$City, $State, $Country";
	    ($Latitude,$Longitude) = &getLatLong($Address);
	}
    }
    my  $PSVersion = '';
    if  ($page =~ />pS-Performance Toolkit<\/a><\/td><td>([\.\d]+)/) {
	 $PSVersion = $1;
    } else {
	warn  "Unable  to  find PS  Version  for  $member\n"
    }
    my $AdminName = '';
    if  ($page =~ /<td>Administrator Name<\/td><td>([^<]+)</)  {
	$AdminName = $1;
    }  else  {
	warn "Host $member is missing Administrator Name\n";
    }
    my $AdminEmail = '';
    if  ($page =~ /<td>Administrator Email<\/td><td><a href="mailto:[^"]*">([^<]+)</)  {
	$AdminEmail = $1;
    }  else  {
	warn "Host $member is missing Administrator Email\n";
    }
    print  "   Found  City:$City State:$State Country:$Country\n";
    print  "   Found  Latitude:$Latitude Longitude:$Longitude\n";
    print  "   Found  PSVersion:$PSVersion\n";
    print  "   Found  AdminName:$AdminName AdminEmail:$AdminEmail\n";
}  else  {
    print  $response->status_line."\n";
}
exit;
