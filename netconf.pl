#!/usr/local/bin/perl

$target = "192.168.2.3";

use SOAP::Lite +trace => 'debug';

$service = SOAP::Lite -> service('http://$target:832/onapi/');

print "hgehoge";

#$result = $service->getXML_DDBJEntry("get-config");

print SOAP::Lite->get-config()->result;
#print SOAP::Lite->getStateName(1)->result;
