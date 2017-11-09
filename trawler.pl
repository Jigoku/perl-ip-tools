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
	
main();

sub genaddress(){
	
	my @n = ();
	# filter experimental/multicast
	$n[0] = int(rand(223)) + 1;                    
	$n[1] = int(rand(254)) + 1;
	$n[2] = int(rand(254)) + 1;
	$n[3] = int(rand(254)) + 1;
	# discard loopbacks and private
	if($n[0] == 127 || $n[0] == 172 || $n[0] == 192 || $n[0] == 10){
		&genaddress();
	} else {
		return join(".",@n);
	}
}


sub connect {
		my $target = &genaddress();
		
		my $sock = new IO::Socket::INET (
			 PeerAddr => $target,
			 PeerPort => $port,
			 Proto => 'tcp',
			 Timeout => $time
		);

		if($sock) {
			print "[${green}+${clear}] Open\t${green}${target}:${port}${clear}\n";
			open(DAT, ">>result.txt") || die("Cannot Open Output File");
			print DAT "$target $port\n";
			close(DAT);
			close($sock);
			
		} else {
			print "[${blue}-${clear}] Closed\t${target}:${port}\n";
		}
		
		threads->self()->detach;
}

sub main {
	print "-"x50 ."\n";
	print "    Started random seek\n";
	print "-"x50 ."\n";
	print "    port=${port}\t time=". $time*1000 . "ms\t threads=". $threads . "\n";
	print "-"x50 ."\n";
	
	while(1){
		if (scalar(threads->list()) < $threads) {
			my $thr = threads->new(\&connect);
		}
	}
}
