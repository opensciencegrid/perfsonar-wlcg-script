#!/usr/bin/perl
#
#  Script to parse v3.4 info JSON from perfSONAR-PS host
#
#  Example use :  ./parse-host34-info.pl  ps-lat.aglt2.org
#
#  Initial  version  from  Shawn  McKee  <smckee@umich.edu>
#  October  5, 2014
#################################################################################
use LWP::Simple;
use JSON qw( decode_json );
use Data::Dumper;
use strict;
use warnings;

my $member=$ARGV[0];

#my %psinfo = {};
#$psinfo{$member} = $member;

# Initialize  HOST  url
my $HOSTJSON = "http://$member/toolkit/index.cgi?format=json";

# Setup loop over all relevant  URLS
print  "  Processing host info from $member...\n";
my $url =  $HOSTJSON;
my $json = get( $url ); 
warn "Could not get $url for $member!"  unless  defined  $json;

my $decoded_json = decode_json($json);

#  Use the line below  to  understand  the  JSON  data structure.  Comment out when done
#print Dumper $decoded_json;

print "  Finding details for host $member...\n";
print  "  Found  ntp synchronized:".$decoded_json->{ntp}{synchronized}."\n";
#exit
print  "  Location details:\n";
print  "     country   ".$decoded_json->{location}{country}."\n";
print  "     city      ".$decoded_json->{location}{city}."\n";
print  "     latitude  ".$decoded_json->{location}{latitude}."\n";
print  "     longitude ".$decoded_json->{location}{longitude}."\n";
print  "     zipcode   ".$decoded_json->{location}{zipcode}."\n";
print  "     state     ".$decoded_json->{location}{state}."\n";

my @services = @{ $decoded_json->{services} };
# Process  the  mesh-url  to  find  the  tests and hosts involved
foreach my $service ( @services ) {
#  First  test description
    print "  Service name : ".$service->{name} . "\n";
    print "     is_running :  ".$service->{is_running}."\n";
    print "     version :  ".$service->{version}."\n";
    if  (defined  $service->{addresses} )  {
	my @servaddr = @{ $service->{addresses} };
	foreach my  $addr ( @servaddr ) {
	    print "       address : ".$addr."\n";
	}
    }
    if  (defined  $service->{testing_ports} )  {
        print "       testing_ports\n";
	my @tportptr = @{ $service->{testing_ports} };
	foreach my  $tptr ( @tportptr ) {
	    print "         type     : ".$tptr->{type}."\n";
	    print "         min_port : ".$tptr->{min_port}."\n";
	    print "         max_port : ".$tptr->{max_port}."\n";
	}
    }
}
# Meshes?
my @meshes = @{ $decoded_json->{meshes} };
foreach my $mesh ( @meshes ) {
#  First  test description
    print "   Participates in mesh : ".$mesh. "\n";
}
print "   Toolkit version : ".$decoded_json->{toolkit_version}. "\n";

# keywords (communities)
my @comms = @{ $decoded_json->{keywords} };
foreach my $comm ( @comms ) {
#  First  test description
    print "   Advertises keyword/community : ".$comm. "\n";
}
print "   Toolkit RPM version : ".$decoded_json->{toolkit_rpm_version}. "\n";
print "   Administrator name  : ".$decoded_json->{administrator}{name}. "\n";
print "   Administrator email : ".$decoded_json->{administrator}{email}. "\n";
print "   External address dns  : ".$decoded_json->{external_address}{address}. "\n";
defined $decoded_json->{external_address}{ipv4_address} && print "   External address ipv4 : ".$decoded_json->{external_address}{ipv4_address}. "\n";
defined $decoded_json->{external_address}{ipv6_address} && print "   External address ipv6 : ".$decoded_json->{external_address}{ipv6_address}. "\n";
print "   External address mtu : ".$decoded_json->{external_address}{mtu}. "\n";
print "   Globally registered : ".$decoded_json->{globally_registered}. "\n";

exit;
