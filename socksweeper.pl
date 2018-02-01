#!/usr/bin/env perl
# threaded socks proxy checker
# based on storm's (GNY) socks-valid.pl
#
# usage; ./$0 <proxylist> <threads> <timeout>
#
use strict;
use warnings;
use IO::Socket;
use threads;
use threads::shared;

my $proxylist = $ARGV[0];		# input file
my $validlist = "validlist";	# output file
my $threads   = $ARGV[1] || 5;	# max threads
my $timeout   = $ARGV[2] || 3;	# connection timeout

#-----------------------------------------------------#

open FILE, "<$proxylist" or die "[-] $!\n";
	my @socks = <FILE>;
close FILE;

my $total = scalar(@socks);
my $valid :shared = 0;


sub connect_sock($) {
	our ($addr, $port) = split(/:/, shift, 2);
	our $sock = IO::Socket::INET->new (
    	PeerAddr => $addr,
    	PeerPort => $port,
	    Proto    => 'tcp',
		Timeout  => $timeout,
	) or warn "[-] $! ($addr:$port)\n";
		
	if ($sock) {
		open VALID, ">>$validlist" or die "[-]$!\n";
	        print VALID "$addr:$port\n";
   		close VALID;
		print "[+] Connected ($addr:$port)\n";
		close $sock; $valid++;
	}
	
	threads->self()->detach;
}

sub cleanup {
	sleep 1 while threads->list();
	print "valid: $valid / $total\n";
}

$SIG{'INT'} = sub { 
	print "\nCaught SIGINT, waiting for remaining threads...\n";
	&cleanup();
	exit 2;
};



package main;

while (@socks > 0) {
	if (threads->list() < $threads) {
		our $l = shift(@socks);
		if ($l =~ m/(\d+).(\d+).(\d+).(\d+):(\d+)/g) {	
			$l =~ s/[\r\n]+//g;
			threads->new(\&connect_sock, $l);
		}
	}	
}

&cleanup();
