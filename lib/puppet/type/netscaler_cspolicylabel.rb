require 'puppet/parameter/netscaler_name'
require 'puppet/property/netscaler_truthy'
require 'puppet/property/netscaler_traffic_domain'

Puppet::Type.newtype(:netscaler_cspolicylabel) do
  @doc = 'Manage basic netscaler cs action objects.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)
  #XXX Validat with the below
  #ensure: change from absent to present failed: Could not set 'present' on ensure: REST failure: HTTP status code 400 detected.  Body of failure is: { "errorcode": 1075, "message": "Invalid name; names must begin with an alphanumeric character or underscore and must contain only alphanumerics, '_', '#', '.', ' ', ':', '@', '=' or '-' [name, hunner's website]", "severity": "ERROR" } at 55:/etc/puppetlabs/puppet/environments/produc

  newproperty(:label_type) do
    desc "Protocol supported by the policy label. All policies bound to the policy label must either match the specified protocol or be a subtype of that protocol. Available settings function as follows:
* HTTP - Supports policies that process HTTP traffic. Used to access unencrypted Web sites. (The default.)
* SSL - Supports policies that process HTTPS/SSL encrypted traffic. Used to access encrypted Web sites.
* TCP - Supports policies that process any type of TCP traffic, including HTTP.
* SSL_TCP - Supports policies that process SSL-encrypted TCP traffic, including SSL.
* UDP - Supports policies that process any type of UDP-based traffic, including DNS.
* DNS - Supports policies that process DNS traffic.
* ANY - Supports all types of policies except HTTP, SSL, and TCP.
* SIP_UDP - Supports policies that process UDP based Session Initiation Protocol (SIP) traffic. SIP initiates, manages, and terminates multimedia communications sessions, and has emerged as the standard for Internet telephony (VoIP).
* RTSP - Supports policies that process Real Time Streaming Protocol (RTSP) traffic. RTSP provides delivery of multimedia and other streaming data, such as audio, video, and other types of streamed media.
* RADIUS - Supports policies that process Remote Authentication Dial In User Service (RADIUS) traffic. RADIUS supports combined authentication, authorization, and auditing services for network management.
* MYSQL - Supports policies that process MYSQL traffic.
* MSSQL - Supports policies that process Microsoft SQL traffic."
    validate do |value|
      if ! [
        :HTTP,
        :ANY,
        :DIAMETER,
        :DNS,
        :DNS_TCP,
        :FTP,
        :MSSQL,
        :MYSQL,
        :ORACLE,
        :RADIUS,
        :RDP,
        :RTSP,
        :SIP_UDP,
        :SSL,
        :SSL_DIAMETER,
        :SSL_TCP,
        :TCP,
        :UDP,
      ].include? value.to_sym
        fail ArgumentError, "Valid options: HTTP, TCP, RTSP, SSL, SSL_TCP, UDP, DNS, SIP_UDP, ANY, RADIUS, RDP, MYSQL, MSSQL, ORACLE, DIAMETER, SSL_DIAMETER, FTP, DNS_TCP" 
      end
    end

  end

  newproperty(:comments) do
    desc "Any comments to preserve information about this cs policy label."
  end
end
