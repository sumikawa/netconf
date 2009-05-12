#!/usr/local/bin/perl
use strict;
use SOAP::Lite;
require 'netconf.pl';

my @targets = ( "192.168.2.3", "192.168.1.222", "192.168.1.223", );
my $gitdir = "/Users/sumikawa/configs";

for (@targets) {
    print ("Conect to $_\n");
    my $service = setup($_);
    open(FH, "> $gitdir/$_.txt") || die "cannot open $gitdir/$_.txt";
    hello($service);
    print FH getconfig($service)->valueof('//rpc-reply/rpc-reply/data/ConfigData');
    closesession($service);
    close(FH)
}
print ("Commiting...\n");

chdir($gitdir);
system("git add .");
my @tmp = localtime(time);
my $d = sprintf("%04d%02d%02d_%02d%02d", $tmp[5] + 1900, $tmp[4] + 1, $tmp[3], $tmp[4], $tmp[5]);
system("git diff");
system("git commit -a -m $d");

print ("Finish.\n");

exit;
