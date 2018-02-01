#!/usr/bin/env perl
use strict;
use warnings;
use IO::Socket;
use threads;

if ($#ARGV < 2) {
	print "usage: perl $0 <port> <timeout> <threads>\n\n";
	exit 2;
}


my $port = $ARGV[0];
my $time = $ARGV[1];
my $threads = $ARGV[2];

#colors
my $green = "\033[1;31m";
my $blue = "\033[0;36m";
my $clear = "\033[0m";


$SIG{'INT'} = sub { 
	sleep 1 while threads->list();
	close(DAT);
	die "Finished.\n";
};


sub genaddress(){
	
	my @n = ();
	# filter experimental/multicast
	$n[0] = int(rand(223)) + 1;    
	
	# discard loopbacks and private
	if($n[0] =~ m/^(127|172|192|10)$/ ) {
		&genaddress();
	} else {                
		
		$n[1] = int(rand(254)) + 1;
		$n[2] = int(rand(254)) + 1;
		$n[3] = int(rand(254)) + 1;

		return join(".",@n);
	}
}


sub connect {
	my $addr = &genaddress();
		
	my $sock = new IO::Socket::INET (
		 PeerAddr => $addr,
		 PeerPort => $port,
		 Proto => 'tcp',
		 Timeout => $time
	) or warn "[${blue}-${clear}] $! ${addr}:${port}\n";

	if ($sock) {
		print "[${green}+${clear}] Connected ${green}${addr}:${port}${clear}\n";
		print DAT "${addr}:${port}\n";

		
		#curl -sI
#		use LWP::UserAgent;
#		my $ua = new LWP::UserAgent;
#		my $url = "http://".$addr.":".$port;
#		my $resp = $ua->get($url);
#		print $resp->protocol, ' ', $resp->status_line, "\n";
#		print $resp->headers_as_string, "\n";

		close($sock);
	}
		
	threads->self()->detach;
}



package main;

print "-"x50 ."\n";
print "    Started random seek\n";
print "-"x50 ."\n";
print "    port=${port}\t time=". $time*1000 . "ms\t threads=". $threads . "\n";
print "-"x50 ."\n";
open(DAT, ">>result.txt") || die("Cannot Open Output File");
	
while(1){
	if (threads->list() < $threads) {
		threads->new(\&connect);
	}
}

