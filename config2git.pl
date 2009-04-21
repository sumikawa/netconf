#!/usr/local/bin/perl

use strict;
use SOAP::Lite;
require 'netconf.pl';

my @targets = ( "192.168.2.3", "192.168.1.223", );
my $gitdir = "/Users/sumikawa/configs";

for (@targets) {
    print ("Conect to $_\n");
    my $proxy = "http://$_:832/onapi"; # SOAP endpoint URL of Alaxala box

    my $service = SOAP::Lite
	->proxy($proxy, cookie_jar => HTTP::Cookies->new(ignore_discard => 1));
    $service->serializer
	->envprefix("soapenv")	# for alaxala interoperability
	    ->encodingStyle(""); # for alaxala interoperability

    open(FH, "> $gitdir/$_.txt") || die "cannot open $gitdir/$_.txt";
    hello($service);
    print FH getconfig($service)->valueof('//rpc-reply/rpc-reply/data/ConfigData');
    closesession($service);
    close(FH)
}
print ("Commting...\n");

chdir($gitdir);
system("git add .");
my @tmp = localtime(time);
my $d = sprintf("%04d%02d%02d_%02d%02d", $tmp[5] + 1900, $tmp[4] + 1, $tmp[3], $tmp[4], $tmp[5]);
system("git commit -a -m $d");

print ("Finish.\n");
exit;
