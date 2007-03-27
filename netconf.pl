#!/usr/local/bin/perl

$target = "192.168.2.3";
$proxy = "http://$target:832/onapi/";  # SOAP service URL of Alaxala box

use HTTP::Cookies;
use SOAP::Lite
#    +trace => 'debug'
;

my $service = SOAP::Lite
    ->proxy($proxy, cookie_jar => HTTP::Cookies->new(ignore_discard => 1));
$service->serializer
    ->envprefix("soapenv")
    ->encodingStyle(""); # remove encoding attributes from envelope header

# build and send a "hello" message
# this is like "Omajinai".  You don't need to modify this section
@hello = (
    SOAP::Data->name("capabilities" => \SOAP::Data->value(
			 SOAP::Data->name('capability' => "net:alaxala:oan:onapi:1.1"),
			 SOAP::Data->name('capability' => "urn:ietf:params:xml:ns:netconf:capability:startup:1.0"),
			 SOAP::Data->name('capability' => "urn:ietf:params:xml:ns:capability:writable-running:1.0"),    
			 SOAP::Data->name('capability' => "urn:ietf:params:xml:ns:netconf:base:1.0"),
		     )),
    SOAP::Data->name("session-id"),
    );
$service->call(SOAP::Data->name('hello')
	       ->attr({xmlns => 'urn:ietf:params:xml:ns:netconf:base:1.0'}) 
	       => @hello);

# Get configuration
# you need to modify the below section depending on what do you want to do
$rpc3 = SOAP::Data->name("source" => \SOAP::Data->value(
			     SOAP::Data->name('running')));
$rpc2 = SOAP::Data->name("get-config" => \SOAP::Data->value($rpc3));
$rpc1 = SOAP::Data->name("rpc" => \SOAP::Data->value($rpc2))
    ->attr({"message-id" => "710"});

$result = $service
    ->call(SOAP::Data->name('rpc')
	   ->attr({'xmlns' => "urn:ietf:params:xml:ns:netconf:base:1.0"})
	   => \SOAP::Data->value($rpc1));

print $result->valueof('//rpc-reply/rpc-reply/data/ConfigData');
