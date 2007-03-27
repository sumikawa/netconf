#!/usr/local/bin/perl
#$Id$

use strict;
use HTTP::Cookies;
use SOAP::Lite;
#use SOAP::Lite +trace => 'debug';

my $target = shift || "192.168.2.3";
my $proxy = "http://$target:832/onapi/";  # SOAP service URL of Alaxala box
my $namespace = "urn:ietf:params:xml:ns:netconf:base:1.0";

my $service = SOAP::Lite
    ->proxy($proxy, cookie_jar => HTTP::Cookies->new(ignore_discard => 1));
$service->serializer
    ->envprefix("soapenv")
    ->encodingStyle(""); # remove encoding attributes from the envelope header

hello();
my $result = getconfig();

print $result->valueof('//rpc-reply/rpc-reply/data/ConfigData');

sub hello
{
# build and send a "hello" message
# this is like "Omajinai".  You don't need to modify this funxtion
my @hello = (
    SOAP::Data->name("capabilities" => \SOAP::Data->value(
			 SOAP::Data->name('capability' => "net:alaxala:oan:onapi:1.1"),
			 SOAP::Data->name('capability' => "urn:ietf:params:xml:ns:netconf:capability:startup:1.0"),
			 SOAP::Data->name('capability' => "urn:ietf:params:xml:ns:capability:writable-running:1.0"),    
			 SOAP::Data->name('capability' => $namespace),
		     )),
    SOAP::Data->name("session-id"),
    );

$service->call(SOAP::Data->name('hello')
	       ->attr({xmlns => $namespace}) 
	       => @hello);
}

sub getconfig
{
my $rpc3 = SOAP::Data->name("source" => \SOAP::Data->value(
				SOAP::Data->name('running')));
my $rpc2 = SOAP::Data->name("get-config" => \SOAP::Data->value($rpc3));
my $rpc1 = SOAP::Data->name("rpc" => \SOAP::Data->value($rpc2))
    ->attr({"message-id" => "710"});

return $service->call(SOAP::Data->name('rpc')
		      ->attr({'xmlns' => $namespace})
		      => \SOAP::Data->value($rpc1));
}
