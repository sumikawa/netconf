#!/usr/local/bin/perl

use strict;
use HTTP::Cookies;
#use SOAP::Lite;
use SOAP::Lite +trace => 'debug';

my $target = shift || die "usage: $0 [Alaxala box's IP address]\n";
my $proxy = "http://$target:832/onapi/";  # SOAP endpoint URL of Alaxala box
my $namespace = "urn:ietf:params:xml:ns:netconf:base:1.0";

my $service = SOAP::Lite
    ->proxy($proxy, cookie_jar => HTTP::Cookies->new(ignore_discard => 1));
$service->serializer
    ->envprefix("soapenv") # for alaxala interoperability
    ->encodingStyle("");   # for alaxala interoperability

hello($service);
print getconfig($service)->valueof('//rpc-reply/rpc-reply/data/ConfigData');
closesession($service);

exit;

sub hello
{
    my $service = shift;
    my @hello = (
	SOAP::Data->name("capabilities" => \SOAP::Data->value(
			     SOAP::Data->name('capability' => "net:alaxala:oan:onapi:1.1"),
			     SOAP::Data->name('capability' => "urn:ietf:params:xml:ns:netconf:capability:startup:1.0"),
			     SOAP::Data->name('capability' => "urn:ietf:params:xml:ns:capability:writable-running:1.0"),    
			     SOAP::Data->name('capability' => $namespace),
			 )),
	SOAP::Data->name("session-id"),
	);

    return $service->call(SOAP::Data->name('hello')
			  ->attr({xmlns => $namespace}) 
			  => @hello);
}

sub closesession
{
    my $service = shift;
    my $rpc2 = SOAP::Data->name("close-session")
	->type("ns1:closeSessionType");
    my $rpc1 = SOAP::Data->name("rpc" => \SOAP::Data->value($rpc2))
	->attr({"message-id" => "713"});
    return $service->call(SOAP::Data->name('rpc')
			  ->attr({'xmlns' => $namespace})
			  => $rpc1);
}

sub getconfig
{
    my $service = shift;
    my $rpc3 = SOAP::Data->name("source" => \SOAP::Data->value(
				    SOAP::Data->name('running')));
    my $rpc2 = SOAP::Data->name("get-config" => \SOAP::Data->value($rpc3));
    my $rpc1 = SOAP::Data->name("rpc" => \SOAP::Data->value($rpc2))
	->attr({"message-id" => "710"});
    
    return $service->call(SOAP::Data->name('rpc')
			  ->attr({'xmlns' => $namespace})
			  => $rpc1);
}

#$Id$
