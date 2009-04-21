#!/usr/local/bin/perl

use strict;
use SOAP::Lite;
require 'netconf.pl';

my $target = shift || die "usage: $0 [Alaxala box's IP address]\n";
my $proxy = "http://$target:832/onapi";	# SOAP endpoint URL of Alaxala box

my $service = SOAP::Lite
    ->proxy($proxy, cookie_jar => HTTP::Cookies->new(ignore_discard => 1));
$service->serializer
    ->envprefix("soapenv")	# for alaxala interoperability
    ->encodingStyle("");	# for alaxala interoperability

hello($service);
print getconfig($service)->valueof('//rpc-reply/rpc-reply/data/ConfigData');
closesession($service);

exit;
