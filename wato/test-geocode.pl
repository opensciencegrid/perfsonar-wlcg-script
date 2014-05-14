#!/usr/bin/perl
#
#  Test geocode.pl subroutine
#
#    Pass in an address  string  on  the  comand line
#
#  Shawn  McKee <smckee@umich.edu>
#    December  30,  2013
##############################

require  "geocode.pl";

$address = $ARGV[0];

#print  "  Address is  |$address|\n";

my ($lat, $long) =  &getLatLong($address);

print  "Found LAT:$lat LONG:$long for \"$address\"\n";
exit;
