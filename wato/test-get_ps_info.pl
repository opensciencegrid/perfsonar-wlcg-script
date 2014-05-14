#!/usr/bin/perl
#
#  Script to test the get_ps_info.pl subroutine
#
#  Call like 'perl  test-get_ps_info.pl  <FQDN-of-Host-to-find-info-on>'
#
#  Initial  version  from  Shawn  McKee  <smckee@umich.edu>
#  December  27, 2013
#################################################################################
use strict;
use warnings;

#  This  is  the  subroutine  which  does  the  work
require "get_ps_info.pl";

if ($#ARGV < 0 ) {
    print STDERR "You must enter a Host (FQDN)\n";
    exit(1);
}

my $HostToFind=$ARGV[0];

# Debug  variable
my $debug = 0;

my %hostinfo;

$hostinfo{"HostToFind"}=$HostToFind;

&get_ps_info(\%hostinfo);

print  " Found these values for host $HostToFind:\n";
foreach  my $key (  sort keys %hostinfo  )  {
    print  "  $key = ".$hostinfo{$key}."\n";
}  

exit;
