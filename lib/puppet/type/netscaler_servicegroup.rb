require 'puppet/parameter/netscaler_name'
require 'puppet/property/netscaler_truthy'
require 'puppet/property/netscaler_traffic_domain'

Puppet::Type.newtype(:netscaler_servicegroup) do
  @doc = 'Configuring a service group enables you to manage a group of services as easily as a single service. For example, if you enable or disable any option, such as compression, health monitoring or graceful shutdown, for a service group, the option gets enabled for all the members of the service group.'

  apply_to_device
  ensurable

  ## creation properties

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)

  newproperty(:protocol) do
    desc 'Protocol in which data is exchanged with the service group. Required.'
    validate do |value|
      if ! [
        :ADNS,
        :ADNS_TCP,
        :ANY,
        :DHCPRA,
        :DIAMETER,
        :DNS,
        :DNS_TCP,
        :DTLS,
        :FTP,
        :HTTP,
        :MSSQL,
        :MYSQL,
        :NNTP,
        :ORACLE,
        :RADIUS,
        :RDP,
        :RPCSVR,
        :RTSP,
        :SIP_UDP,
        :SNMP,
        :SSL,
        :SSL_BRIDGE,
        :SSL_DIAMETER,
        :SSL_TCP,
        :TCP,
        :TFTP,
        :UDP,
      ].include? value.to_sym
        fail ArgumentError, "Valid options: HTTP, FTP, TCP, UDP, SSL, SSL_BRIDGE, SSL_TCP, DTLS, NNTP, RPCSVR, DNS, ADNS, SNMP, RTSP, DHCPRA, ANY, SIP_UDP, DNS_TCP, ADNS_TCP, MYSQL, MSSQL, ORACLE, RADIUS, RDP, DIAMETER, SSL_DIAMETER, TFTP"
      end
    end
  end

  newproperty(:traffic_domain_id, :parent => Puppet::Property::NetscalerTrafficDomain)

  newproperty(:cache_type) do
    desc "Cache type supported by the cache server."
    validate do |value|
      if ! [
        :SERVER,
        :TRANSPARENT,
        :REVERSE,
        :FORWARD,
      ].include? value.to_sym
        fail ArgumentError, "Valid options: SERVER, TRANSPARENT, REVERSE, FORWARD"
      end
    end
  end

  newproperty(:autoscale_mode) do
    desc "Auto scale option for a servicegroup."
    validate do |value|
      if ! [
        :DISABLED,
        :DNS,
        :POLICY,
      ].include? value.to_sym
        fail ArgumentError, "Valid options: DISABLED, DNS, POLICY"
      end
    end
  end

  newproperty(:member_port) do
    desc "The port for the service group members. Only valid when autoscale_mode is POLICY."
    validate do |value|
      if ! (value =~ /^\d+$/ and Integer(value).between?(1,65535))
        fail ArgumentError, "member_port: #{value} is not a valid port."
      end
    end
    munge do |value|
      Integer(value)
    end
  end

  newproperty(:cacheable, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Use the transparent cache redirection virtual server to forward requests to the cache server. May not be specified if cache_type is 'TRANSPARENT', 'REVERSE', or 'FORWARD'", 'YES', 'NO')
  end

  newproperty(:state, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("The state of the object.", 'ENABLED', 'DISABLED')
  end

  newproperty(:health_monitoring, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Monitor the health of this service. Available settings function as follows:
YES - Send probes to check the health of the service.
NO - Do not send probes to check the health of the service. With the NO option, the appliance shows the service as UP at all times.", 'YES', 'NO')
  end

  newproperty(:appflow_logging, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Enable logging of AppFlow information.", 'ENABLED', 'DISABLED')
  end

  newproperty(:comments) do
    desc "Any information about the object."
  end

  ## Threshold and timeouts
  newproperty(:maximum_bandwidth) do
    desc "Maximum bandwidth, in Kbps, allocated to the service.

Max = 4294967287"
  end

  newproperty(:monitor_threshold) do
    desc "Minimum sum of weights of the monitors that are bound to this service. Used to determine whether to mark a service as UP or DOWN.

Max = 65535"
  end

  newproperty(:max_requests) do
    desc "Maximum number of requests that can be sent on a persistent connection to the service. 
Note: Connection requests beyond this value are rejected.

Max = 65535"
  end

  newproperty(:max_clients) do
    desc "Maximum number of simultaneous open connections to the service.

Max = 4294967294"
  end

  newproperty(:client_idle_timeout) do
    desc "Time, in seconds, after which to terminate an idle client connection.

Max = 31536000"
    validate do |value|
      if ! value =~ /^\d+$/
        fail ArgumentError, "client_idle_timeout: #{value} is not a valid integer."
      end
    end
    munge do |value|
      Integer(value)
    end
  end

  newproperty(:server_idle_timeout) do
    desc "Time, in seconds, after which to terminate an idle server connection.

Max = 31536000"
    validate do |value|
      if ! value =~ /^\d+$/
        fail ArgumentError, "server_idle_timeout: #{value} is not a valid integer."
      end
    end
    munge do |value|
      Integer(value)
    end
  end

  ## settings

  newproperty(:sure_connect, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("State of SureConnect for the service.", 'ON', 'OFF')
  end

  newproperty(:surge_protection, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Enable surge protection for the service.", 'ON', 'OFF')
  end

  newproperty(:use_proxy_port, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Use the proxy port as the source port when initiating connections with the server. With the NO setting, the client-side connection port is used as the source port for the server-side connection.
Note: This parameter is available only when the Use Source IP (USIP) parameter is set to YES.", 'YES', 'NO')
  end

  newproperty(:down_state_flush, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Flush all active transactions associated with a service whose state transitions from UP to DOWN. Do not enable this option for applications that must complete their transactions.", 'ENABLED', 'DISABLED')
  end

  newproperty(:use_client_ip, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Use the client's IP address as the source IP address when initiating a connection to the server. When creating a service, if you do not set this parameter, the service inherits the global Use Source IP setting (available in the enable ns mode and disable ns mode CLI commands, or in the System > Settings > Configure modes > Configure Modes dialog box). However, you can override this setting after you create the service.", 'YES', 'NO')
  end

  newproperty(:client_keepalive, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Enable client keep-alive for the service.", :'YES', 'NO')
  end

  newproperty(:tcp_buffering, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Enable TCP buffering for the service.", 'YES', 'NO')
  end

  newproperty(:http_compression, :parent => Puppet::Property::NetscalerTruthy) do
    desc "Enable compression for the specified service."
  end

  newproperty(:client_ip, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Before forwarding a request to the service, insert an HTTP header with the client's IPv4 or IPv6 address as its value. Used if the server needs the client's IP address for security, accounting, or other purposes, and setting the Use Source IP parameter is not a viable option.", 'ENABLED', 'DISABLED')
  end

  newproperty(:client_ip_header) do
    desc "Name for the HTTP header whose value must be set to the IP address of the client. Used with the Client IP parameter. If you set the Client IP parameter, and you do not specify a name for the header, the appliance uses the header name specified for the global Client IP Header parameter (the cipHeader parameter in the set ns param CLI command or the Client IP Header parameter in the Configure HTTP Parameters dialog box at System > Settings > Change HTTP parameters). If the global Client IP Header parameter is not specified, the appliance inserts a header with the name \"client-ip.\""
  end

  ## profiles

  newproperty(:tcp_profile) do
    desc "Name of the TCP profile that contains TCP configuration settings for the service group."
  end

  newproperty(:http_profile) do
    desc "Name of the HTTP profile that contains HTTP configuration settings for the service group."
  end

  newproperty(:net_profile) do
    desc "Network profile for the service group."
  end

  ## Extra properties follow
  newparam(:graceful_shutdown, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Indicates graceful shutdown of the server. System will wait for all outstanding connections to this server to be closed before disabling the server.", "YES", "NO")
  end

  validate do
    if self[:member_port] and self[:autoscale_mode] != 'POLICY'
      err "Setting member_port requires autoscale_mode of POLICY"
    end
  end
end
