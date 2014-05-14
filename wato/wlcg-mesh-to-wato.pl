#!/usr/bin/perl
#
#  Script  to  parse  JSON from  WLCG  mesh-config  for  perfSONAR-PS monitoring
#   and  create  configuration  lines  in  OMD WATO
#
#  Initial  version  from  Shawn  McKee  <smckee@umich.edu>
#  December  26, 2013
#  Updated  December  27 to add  get_ps_info routine
#################################################################################
use LWP::Simple;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use JSON qw( decode_json );
use Data::Dumper;
use strict;
use warnings;

require "get_ps_info.pl";
require "geocode.pl";
require "geoaddress.pl";
 
# Initialize  WLCGURL hash
my %WLCGURLS  =  ();
$WLCGURLS{WLCG} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-wlcg-all.json";
$WLCGURLS{USATLAS} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-us-atlas.json";
$WLCGURLS{USCMS} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-us-cms.json";
$WLCGURLS{UK} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-uk-all.json";
$WLCGURLS{ITATLAS} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-it-atlas.json";
$WLCGURLS{ITCMS} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-it-cms.json";
$WLCGURLS{CA} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-ca-all.json";
$WLCGURLS{FR} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-fr-all.json";
$WLCGURLS{TW} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-tw-all.json";
$WLCGURLS{NL} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-nl-all.json";
$WLCGURLS{DE} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-de-all.json";
$WLCGURLS{ES} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-es-all.json";
$WLCGURLS{CERN} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-cern-all.json";
$WLCGURLS{RU} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-ru-all.json";
$WLCGURLS{LHCOPN} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-opn-all.json";

my %hostline = ();
my $debug =  0;
my %LocLat  = ();
my %LocLong  = ();
my %LocCountry  = ();
my %PSVersion  = ();
my %LookupWorked =  ();

# First create  some  groups we  want to  have:
system("sed  -i  \"/define_hostgroups = {}/a define_hostgroups.update\({'Latency': u'Latency perfSONAR-PS Toolkit nodes'}\)\" groups.mk");
system("sed  -i  \"/define_hostgroups = {}/a define_hostgroups.update\({'Bandwidth': u'Bandwidth perfSONAR-PS Toolkit nodes'}\)\" groups.mk");

#  Make  sure  we  add  rules  for  these  host groups
open(HOSTGROUPS,">host_groups.mk")  or  die "Unable  to  open  host_groups.mk: $!\n";
print  HOSTGROUPS  "# Written by wlcg-mesh-to-wato.pl on ".localtime(time())."\n";
print  HOSTGROUPS  "#\n";
print  HOSTGROUPS  "host_groups = [\n";
print  HOSTGROUPS  "]\n";
close(HOSTGROUPS);
system("sed  -i  \"/host_groups = /a        ( 'Latency',  [ 'owamp' ], ALL_HOSTS ),\" host_groups.mk");
system("sed  -i  \"/host_groups = /a        ( 'Bandwidth',  [ 'bwctl' ], ALL_HOSTS ),\" host_groups.mk");

# Setup loop over all relevant  URLS
foreach my $cloud (  keys %WLCGURLS )  {
    print  "  Processing cloud  $cloud...\n";
#  Create  corresponding  group  for  each  cloud
    system("sed  -i  \"/define_hostgroups = {}/a define_hostgroups.update\({'\"$cloud\"': u'\"$cloud\" perfSONAR-PS Toolkit nodes'}\)\" groups.mk");
#  Add  rule  for  this  group
    system("sed  -i  \"/host_groups = /a        ( '\"$cloud\"',  [ '\"$cloud\"' ], ALL_HOSTS ),\" host_groups.mk");
#    if ($cloud  eq "WLCG"  ) {
#	$debug  =  1;
#    }  else  {
#	$debug =  0;
#    }
    my $url =  $WLCGURLS{$cloud};
    my $json = get( $url ); 
    warn "Could not get $url for $cloud!\n"  unless  defined  $json;
    next  unless  defined  $json;

    my $decoded_json = decode_json($json);

#  Use the line below  to  understand  the  JSON  data structure.  Comment out when done
#print Dumper $decoded_json;

    $debug  && print "  Finding details  for  $url  mesh...\n";
    my @tests = @{ $decoded_json->{'tests'} };
# Process  the  mesh-url  to  find  the  tests and hosts involved
    foreach my $test ( @tests ) {
#  First  test description
	$debug  && print "Description: ".$test->{"description"} . "\n";
	my $type =  $test->{"members"}{"type"};
	$debug  && print "Type:  ".$type."\n";
#  Get  parameters for  this  test
	my $testtype =  $test->{"parameters"}{"type"};
        my ($pt,$tt) =  split(/\//,$testtype);   # Extract owamp  or  bwctl into $tt
	if  (!defined  $tt) {
	    warn  "Unable  to  find  tt for  cloud  $cloud  and description ".$test->{"descripion"}."\n";
	    next;
	}
	$debug  && print "Test Type:  ".$testtype." and  tt: ".$tt."\n";
        
	if  (  $type eq "mesh" )  {
	    foreach  my $member  (  @{ $test->{"members"}{"members"} } ) {
		$debug && print "\tMember: ".$member. "\n";
# Now  we have  a host and can get information  from  hLS
		my %hostinfo=();
		$hostinfo{HostToFind}=$member;
		&get_ps_info(\%hostinfo);
# Did  we  find  anything?
		if  (exists  $hostinfo{"location-latitude"})  {
# Now we have a hash containing the  host  details.   Dump  lat/long
		    $LocLat{$member}=$hostinfo{"location-latitude"};
		    $LocLong{$member}=$hostinfo{"location-longitude"};
		    $LocCountry{$member}=$hostinfo{"location-country"};
# Likely want  to  have groups  by country
		    if ( exists  $LocCountry{$member} ) {
		        $LookupWorked{$member} =  1;
			my $Country=$LocCountry{$member};
			if  ( defined  $Country ) {
			    #  Does  this  country  group  exist?
			    my  $iret = system("grep -q \"\'$Country\'\" groups.mk");
			    if  ($iret == 256)  {
				# Add country group (NOT YET;  clash with  cloud?!)
#			    system("sed  -i  \"/define_hostgroups = {}/a define_hostgroups.update\({'\"$Country\"': u'perfSONAR-PS Toolkit nodes from \"$Country\"'}\)\" groups.mk");
				# Add rule  to populate  group
#			    system("sed  -i  \"/host_groups = /a        ( '\"$Country\"',  [ '\"$Country\"' ], ALL_HOSTS ),\" host_groups.mk");
			    }
			}
		    }
		    $PSVersion{$member}=$hostinfo{"pshost-toolkitversion"};
		} else {
#  We  need   to  "screen  scrape"  to get  the  info for  this  host
		    $LookupWorked{$member} =  0;
		    # Get  toolkit  main  page
		    my $ua = new LWP::UserAgent;
		    $ua->timeout(7);  #  Wait  up  to  7  seconds
		    my $toolkit =  "http://$member/toolkit";

		    my $request  =  new  HTTP::Request('GET',$toolkit);
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
			if  ($Country ne  '') {
			    $LocCountry{$member}=$Country;
			}
			my $Latitude = '';
			my $Longitude = '';
			if  ($page =~ /<td>Latitude,Longitude<\/td><td>([-\.\d]+),([-\.\d]+)/)  {
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
			if  ($Latitude ne '' && $Longitude ne ''){
			    $LocLat{$member}=$Latitude;
			    $LocLong{$member}=$Longitude;
			}
			my  $PSVersion = '';
			if  ($page =~ /<tr><td><a rel="external" target="_blank" href="http:\/\/psps.perfsonar.net\/toolkit\/">pS-Performance Toolkit<\/a><\/td><td>([\.\d]+)/) {
			    $PSVersion = $1;
			} else {
			    warn  "Unable  to  find PS  Version  for  $member\n"
			}
			if  ($PSVersion ne  '')  {
			    $PSVersion{$member}=$PSVersion;
			}
#			print  "   Found  City:$City State:$State Country:$Country\n";
#			print  "   Found  Latitude:$Latitude Longitude:$Longitude\n";
#			print  "   Found  PSVersion:$PSVersion\n";
		    }  else  {
			$LookupWorked{$member} =  -1;
			warn  "Problem getting  info on $member\n";
			print  $response->status_line."\n";
		    }
		}
#   At this  point  we  need to build a configuration line  for hosts.mk in  
#   <SITE>/etc/check_mk/conf.d/wato
		if (exists $hostline{$member}) {
		    chomp($hostline{$member});
		    if  (  $hostline{$member} !~ m/$cloud/ ) {
			$hostline{$member} =~  s/wan\|/$cloud\|wan\|/;
		    }
		    if  (  $hostline{$member} !~ m/$tt/ ) {
			$hostline{$member} =~  s/wan\|/$tt\|wan\|/;
		    }
			
		} else {
		    $hostline{$member} =   "\"$member|cmk-agent|prod|perfsonar|$cloud|$tt|wan|tcp|wato|/\" + FOLDER_PATH + \"/\","
		}
	    }
	} elsif ( $type  eq  "disjoint" )  {
	    foreach  my $member  (  @{ $test->{"members"}{"a_members"} } ) {
		$debug  && print "\tA_Member: ".$member. "\n";	
	    }
	    $debug && print "\n";
	    foreach  my $member  (  @{ $test->{"members"}{"b_members"} } ) {
		$debug && print "\tB_Member: ".$member. "\n";
	    }
	}
    }

}    
#  Now  we  have loaded  $hostline for  each  found  host...dump  it
print  "  Insert the following  in  <SiteRoot>/etc/check_mk/conf.d/wato/hosts.mk:\n";
open(OUT,">hosts-add.mk")  or  die  "Unable  to  open  hosts-add.mk:  $!\n";
print OUT "all_hosts += [\n";
foreach my $member  (keys  %hostline)  {
    print  OUT " $hostline{$member}\n"
}
print OUT "]\n";
close(OUT);
print  "  Insert  hosts-add.mk  into  hosts.mk\n\nDone!\n";

# Now  write out  "extra-config"  stanzas
# Latitude
open(OUT,">extra-host-lat.mk")  or  die  "Unable to  open extra-host-lat.mk:  $!\n";
print OUT "extra_host_conf[\"_LAT\"] = [\n";
foreach my $member  (keys  %LocLat)  {
    if  ( defined $LocLat{$member} ) {
	print  OUT "   ( \"".$LocLat{$member}."\", [\"".$member."\" ] ),\n"
    }
}
print OUT "]\n";
close(OUT);
# Longitude
open(OUT,">extra-host-long.mk")  or  die  "Unable to  open extra-host-long.mk:  $!\n";
print OUT "extra_host_conf[\"_LONG\"] = [\n";
foreach my $member  (keys  %LocLong)  {
    if  ( defined $LocLong{$member} ) {
	print  OUT "   ( \"".$LocLong{$member}."\", [\"".$member."\" ] ),\n"
    }
}
print OUT "]\n";
close(OUT);
# Country
open(OUT,">extra-host-country.mk")  or  die  "Unable to  open extra-host-country.mk:  $!\n";
print OUT "extra_host_conf[\"_COUNTRY\"] = [\n";
foreach my $member  (keys  %LocCountry)  {
    if  ( defined $LocCountry{$member} ) {
	print  OUT "   ( \"".$LocCountry{$member}."\", [\"".$member."\" ] ),\n"
    }
}
print OUT "]\n";
close(OUT);
# PS  Version
open(OUT,">extra-host-ps-version.mk")  or  die  "Unable to  open extra-host-ps-version.mk:  $!\n";
print OUT "extra_host_conf[\"_PSVERSION\"] = [\n";
foreach my $member  (keys  %PSVersion)  {
    if  ( defined $PSVersion{$member} ) {
	print  OUT "   ( \"".$PSVersion{$member}."\", [\"".$member."\" ] ),\n"
    }
}
print OUT "]\n";
close(OUT);
# Lookup status
open(OUT,">extra-host-lookup-status.mk")  or  die  "Unable to  open extra-host-lookup-status.mk:  $!\n";
print OUT "extra_host_conf[\"_LOOKUPSTATUS\"] = [\n";
foreach my $member  (keys  %LookupWorked)  {
    if  ( defined $LookupWorked{$member} ) {
	print  OUT "   ( \"".$LookupWorked{$member}."\", [\"".$member."\" ] ),\n"
    }
}
print OUT "]\n";
close(OUT);
print "\nDone!\n";
exit;
