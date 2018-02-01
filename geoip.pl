#!/usr/bin/env perl
# geoip location for proxylists
#
# usage; ./$0 <proxylist>
#        ./$0 <proxylist> | sort

use strict;
use warnings;
use Geo::IP;

Geo::IP->open("/usr/share/GeoIP/GeoIP.dat", GEOIP_STANDARD);

my $proxylist = $ARGV[0];

open FILE, "<$proxylist" or die "[-] $!\n";
	my @socks = <FILE>;
close FILE;


package main;

while (@socks > 0) {
	my $l = shift(@socks);
	$l =~ s/[\r\n]+//g;
 	my ($addr, $port) = split(/:/, $l, 2);

	my $gi = Geo::IP->new(GEOIP_MEMORY_CACHE);
	my $code = $gi->country_code_by_addr($addr) || "??";
	my $name = $gi->country_name_by_addr($addr) || "UNKNOWN";

	if ($code) {
		printf ($code . " | %-25s | ". $name . "\n", "$l");
	}
}
