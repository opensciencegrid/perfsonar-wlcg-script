#!/usr/bin/perl
#
#  Script  to use perfSONAR-PS  hLS to  gather  host  info
#
#  Call like 'perl  get-ps-info.pl  <FQDN-of-Host-to-find-info-on>'
#
#  Initial  version  from  Shawn  McKee  <smckee@umich.edu>
#  December  27, 2013
#################################################################################
use LWP::Simple;
use JSON qw( decode_json );
use Data::Dumper;
use strict;
use warnings;

#  Subroutine  (values  passed  by reference) to find PS  host  info
sub get_ps_info (\%){
    my ($hhptr) = @_;

    my  $debug =  0;

    my $HostToFind = $hhptr->{"HostToFind"};
    $debug && print  " Passed HostToFind $HostToFind\n";
# Initialize  WLCGURL hash
    my $ActivehLSURL="http://ps1.es.net:8096/lookup/activehosts.json";

    my $json = get( $ActivehLSURL ); 
    warn "Could not get $ActivehLSURL!"  unless  defined  $json;

    my $decoded_json = decode_json($json);
#  Use the line below  to  understand  the  JSON  data structure.  Comment out when done
#print Dumper $decoded_json;

    my @Locators=[];
    my $iLoc=0;
    $debug && print " Create list of active hosts...\n";
    my @ActiveHosts = @{ $decoded_json->{'hosts'} };
# Process  the  mesh-url  to  find  the  tests and hosts involved
    foreach my $host ( @ActiveHosts ) {
#  First  test description
	$Locators[$iLoc++]=$host->{"locator"};
	$debug  && print "Host Locator  URL: ".$host->{"locator"} . "\n";
    }
    $debug && print  " Found $iLoc Locator URLs\n";
    for  (my $i=0;$i<$iLoc;$i++)  {
	$debug  && print  "  $i) $Locators[$i]\n";
    }
#  Now  try to  find  information  on  passed  in host
    for  (my $i=0;$i<$iLoc;$i++)  {
	$debug  && print  "  Trying  locator  $i...\n";
	my $URL =  $Locators[$i]."?host-name=$HostToFind";
	my $hostjson = get( $URL ); 
	warn "Could not get $ActivehLSURL!"  unless  defined  $hostjson;
	my $decoded_hostjson = decode_json($hostjson);
# Check to  see if  array $decoded_hostjson  has any  entries; -1 for none
	my  $len =  $#{$decoded_hostjson};
	$debug  && print " len  =  $len\n";
	if  ($len >= 0 ) {
	    $debug && print "  Found  for  $Locators[$i] $decoded_hostjson ".":\n";
#	print Dumper $decoded_hostjson;
# Get 0th element of  array  which is a  pointer  to  a hash
	    my $hashpointer = ${$decoded_hostjson}[0];
#	print  "  hashpointer  $hashpointer\n";
	    foreach my $key (  keys %{$hashpointer} ) {
		$debug && print  "  key =  $key\n";
		if ($key eq "ttl" ||  $key eq  "uri" ||  $key eq "expires" ) {
		    $hhptr->{$key} =  ${$hashpointer}{$key};
		    $debug  && print  "  Found  $key with value ".$hhptr->{$key}."\n";
		}  else  {
#  Check  if  the array has more than  one  entry
		    my  $arrlen = $#{${$hashpointer}{$key}};
		    if  ($arrlen ==  0)  {
			$hhptr->{$key} =  ${$hashpointer}{$key}[0];
			$debug && print  "  Found  $key with value $hhptr->{$key}\n";
		    } else  {
			for  (my $i=0;$i<=$arrlen;$i++) {
			    $hhptr->{$key.$i} =  ${$hashpointer}{$key}[$i];
			    $debug && print  "  Found  $key$i with value $hhptr->{$key.$i}\n";
			}
		    }
		}
	    }
	    $debug && print  "\n";
	}
    }
}
1;
