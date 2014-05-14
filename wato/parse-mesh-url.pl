#!/usr/bin/perl
#
#  Script  to  parse  JSON from  WLCG  mesh-config  for  perfSONAR-PS monitoring
#
#  Initial  version  from  Shawn  McKee  <smckee@umich.edu>
#  December  26, 2013
#################################################################################
use LWP::Simple;
use JSON qw( decode_json );
use Data::Dumper;
use strict;
use warnings;
 
# Initialize  WLCGURL hash
my %WLCGURLS  =  ();
$WLCGURLS{WLCG} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-wlcg-all.json";
$WLCGURLS{USATLAS} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-us-atlas.json";
$WLCGURLS{USCMS} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-us-cms.json";
$WLCGURLS{UK} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-uk-all.json";
$WLCGURLS{ITATLAS} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-it-atlas.json";
$WLCGURLS{ITCMS} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-it-cms.json";
$WLCGURLS{CA} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-ca-alll.json";
$WLCGURLS{FR} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-fr-all.json";
$WLCGURLS{TW} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-tw-alll.json";
$WLCGURLS{NL} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-nl-all.json";
$WLCGURLS{DE} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-de-all.json";
$WLCGURLS{ES} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-es-all.json";
$WLCGURLS{CERN} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-cern-all.json";
$WLCGURLS{RU} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-ru-alll.json";
$WLCGURLS{LHCOPN} = "http://grid-deployment.web.cern.ch/grid-deployment/wlcg-ops/perfsonar/conf/central/testdefs/jsons/tests-opn-alll.json";

# Setup loop over all relevant  URLS
foreach my $cloud (  keys %WLCGURLS )  {
    print  "  Processing cloud  $cloud...\n";
    my $url =  $WLCGURLS{$cloud};
    my $json = get( $url ); 
    warn "Could not get $url for $cloud!"  unless  defined  $json;

    my $decoded_json = decode_json($json);

#  Use the line below  to  understand  the  JSON  data structure.  Comment out when done
#print Dumper $decoded_json;

    print "  Finding details  for  $url  mesh...\n";
    my @tests = @{ $decoded_json->{'tests'} };
# Process  the  mesh-url  to  find  the  tests and hosts involved
    foreach my $test ( @tests ) {
#  First  test description
	print "Description: ".$test->{"description"} . "\n";
	my $type =  $test->{"members"}{"type"};
	print "Type:  ".$type."\n";
#  Get  parameters for  this  test
	my $testtype =  $test->{"parameters"}{"type"};
	print "Test Type:  ".$testtype."\n";

	if  (  $type eq "mesh" )  {
	    foreach  my $member  (  @{ $test->{"members"}{"members"} } ) {
		print "\tMember: ".$member. "\n";
	    }
	} elsif ( $type  eq  "disjoint" )  {
	    foreach  my $member  (  @{ $test->{"members"}{"a_members"} } ) {
		print "\tA_Member: ".$member. "\n";
	    }
	    print "\n";
	    foreach  my $member  (  @{ $test->{"members"}{"b_members"} } ) {
		print "\tB_Member: ".$member. "\n";
	    }
	}
    }

}    
