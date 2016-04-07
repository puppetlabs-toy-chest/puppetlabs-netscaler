require_relative('../../puppet/parameter/netscaler_name')
require_relative('../../puppet/property/netscaler_truthy')
require_relative('../../puppet/property/netscaler_traffic_domain')

Puppet::Type.newtype(:netscaler_service) do
  @doc = 'Manage service on the NetScaler appliance. If the service is domain based, before you create the service, create the server entry by using the add server command. Then, in this command, specify the Server parameter.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)

  #newproperty(:address) do
  #  options = '[ipv4|ipv6|domain name]'
  #  desc "The domain name, IPv4 address, or IPv6 address of the server. When creating an IP address-based server, you can specify the name of the server instead of its IP address, when creating a service.
  #  Valid options: #{options}"
  #  validate do |value|
  #    unless value.match(Resolv::IPv6::Regex) || value.match(Resolv::IPv4::Regex) || value
  #      fail ArgumentError, "#{name} must be: #{options}."
  #    end
  #  end
  #end

  newproperty(:protocol) do
    desc 'Protocol in which data is exchanged with the service. Required.'
    validate do |value|
      if ! [
        :HTTP,
        :FTP,
        :TCP,
        :UDP,
        :SSL,
        :SSL_BRIDGE,
        :SSL_TCP,
        :DTLS,
        :NNTP,
        :RPCSVR,
        :DNS,
        :ADNS,
        :SNMP,
        :RTSP,
        :DHCPRA,
        :ANY,
        :SIP_UDP,
        :DNS_TCP,
        :ADNS_TCP,
        :MYSQL,
        :MSSQL,
        :ORACLE,
        :RADIUS,
        :RDP,
        :DIAMETER,
        :SSL_DIAMETER,
        :TFTP,
      ].any?{ |s| s.to_s.eql? value }
        fail ArgumentError, "Valid options: HTTP, FTP, TCP, UDP, SSL, SSL_BRIDGE, SSL_TCP, DTLS, NNTP, RPCSVR, DNS, ADNS, SNMP, RTSP, DHCPRA, ANY, SIP_UDP, DNS_TCP, ADNS_TCP, MYSQL, MSSQL, ORACLE, RADIUS, RDP, DIAMETER, SSL_DIAMETER, TFTP"
      end
    end

    munge(&:upcase)
  end

  newproperty(:state, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("The state of the object.", 'ENABLED', 'DISABLED')
  end

  newproperty(:server_name) do
    desc "Name of the server that hosts the service. Required."
  end

  newproperty(:port) do
    desc "Port number of the service. Required."
    validate do |value|
      if ! (value =~ /^\d+$/ and Integer(value).between?(1,65535))
        fail ArgumentError, "port: #{value} is not a valid port."
      end
    end
    munge do |value|
      Integer(value)
    end
  end

  ## Extra properties follow
  newparam(:graceful_shutdown, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Indicates graceful shutdown of the server. System will wait for all outstanding connections to this server to be closed before disabling the server.", "YES", "NO")
  end

  newproperty(:traffic_domain_id, :parent => Puppet::Property::NetscalerTrafficDomain) do
  end

  newproperty(:hash_id) do
    desc "A numerical identifier that can be used by hash based load balancing methods. Must be unique for each service.

Minimum value: 1"

    validate do |value|
      if ! (value =~ /^\d+$/ and Integer(value).between?(1,4294967295))
        fail ArgumentError, "hash_id: #{value} must be an integer greater than 0."
      end
    end
    munge do |value|
      Integer(value)
    end
  end

  newproperty(:server_id) do
    desc "Unique identifier for the service. Used when the persistency type for the virtual server is set to Custom Server ID."
  end

  newproperty(:clear_text_port) do
    desc "Port to which clear text data must be sent after the appliance decrypts incoming SSL traffic. Applicable to transparent SSL services."
    validate do |value|
      if ! (value =~ /^\d+$/ and Integer(value).between?(1,65535))
        fail ArgumentError, "port: #{value} is not a valid port."
      end
    end
    munge do |value|
      Integer(value)
    end
  end

  newproperty(:cache_type) do
    desc "Cache type supported by the cache server."
    validate do |value|
      if ! [
        :SERVER,
        :TRANSPARENT,
        :REVERSE,
        :FORWARD,
      ].any?{ |s| s.to_s.eql? value }
        fail ArgumentError, "Valid options: SERVER, TRANSPARENT, REVERSE, FORWARD"
      end
    end

    munge(&:upcase)
  end

  newproperty(:cacheable, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Use the transparent cache redirection virtual server to forward requests to the cache server. May not be specified if cache_type is 'TRANSPARENT', 'REVERSE', or 'FORWARD'", 'YES', 'NO')
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

  ## Properties that show up under edit in the gui
  newproperty(:max_clients) do
    desc "Maximum number of simultaneous open connections to the service.

Max = 4294967294"
  end

  newproperty(:max_requests) do
    desc "Maximum number of requests that can be sent on a persistent connection to the service.
Note: Connection requests beyond this value are rejected.

Max = 65535"
  end

  newproperty(:max_bandwidth) do
    desc "Maximum bandwidth, in Kbps, allocated to the service.

Max = 4294967287"
  end

  newproperty(:monitor_threshold) do
    desc "Minimum sum of weights of the monitors that are bound to this service. Used to determine whether to mark a service as UP or DOWN.

Max = 65535"
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

  newproperty(:access_down, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Use Layer 2 mode to bridge the packets sent to this service if it is marked as DOWN. If the service is DOWN, and this parameter is disabled, the packets are dropped.", 'YES', 'NO')
  end

  newproperty(:use_source_ip, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Use the client's IP address as the source IP address when initiating a connection to the server. When creating a service, if you do not set this parameter, the service inherits the global Use Source IP setting (available in the enable ns mode and disable ns mode CLI commands, or in the System > Settings > Configure modes > Configure Modes dialog box). However, you can override this setting after you create the service.", 'YES', 'NO')
  end

  newproperty(:use_compression, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Enable compression for the service.", 'YES', 'NO')
  end

  newproperty(:client_keepalive, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Enable client keep-alive for the service.", :'YES', 'NO')
  end

  newproperty(:tcp_buffering, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Enable TCP buffering for the service.", 'YES', 'NO')
  end

  newproperty(:client_ip, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Before forwarding a request to the service, insert an HTTP header with the client's IPv4 or IPv6 address as its value. Used if the server needs the client's IP address for security, accounting, or other purposes, and setting the Use Source IP parameter is not a viable option.", 'ENABLED', 'DISABLED')
  end

  newproperty(:client_ip_header) do
    desc "Name for the HTTP header whose value must be set to the IP address of the client. Used with the Client IP parameter. If you set the Client IP parameter, and you do not specify a name for the header, the appliance uses the header name specified for the global Client IP Header parameter (the cipHeader parameter in the set ns param CLI command or the Client IP Header parameter in the Configure HTTP Parameters dialog box at System > Settings > Change HTTP parameters). If the global Client IP Header parameter is not specified, the appliance inserts a header with the name \"client-ip.\""
  end

  newproperty(:net_profile_name) do
    desc "Network profile to use for the service."
  end

  #newparam(:graceful_shutdown, :parent => Puppet::Property::NetscalerTruthy) do
  #  truthy_property("Indicates graceful shutdown of the server. System will wait for all outstanding connections to this server to be closed before disabling the server.", "YES", "NO")
  #end

  #newproperty(:translation_ip_address) do
  #  desc "IP address used to transform the server's DNS-resolved IP address."
  #  validate do |value|
  #    if ! value.match(Resolv::IPv4::Regex)
  #      raise ArgumentError, "translation_ip_address must be an IPv4 address."
  #    end
  #  end
  #end

  #newproperty(:translation_mask) do
  #  desc "The netmask of the translation ip"
  #  validate do |value|
  #    if ! value.match(Resolv::IPv4::Regex)
  #      raise ArgumentError, "translation_mask must be an IPv4 address."
  #    end
  #  end
  #end

  #newproperty(:resolve_retry) do
  #  desc "Time, in seconds, for which the NetScaler appliance must wait, after DNS resolution fails, before sending the next DNS query to resolve the domain name.

  #Default = 5
  #Min = 5
  #Max = 20939"
  #end

  #newproperty(:ipv6_domain, :parent => Puppet::Property::NetscalerTruthy) do
  #  truthy_property("Support IPv6 addressing mode. If you configure a server with the IPv6 addressing mode, you cannot use the server in the IPv4 addressing mode", "YES", "NO")
  #end

  ### This is handled with the "state" property
  ##newparam(:enable_after_creating, :parent => Puppet::Property::NetscalerTruthy) do
  ##  truthy_property("Initial state of the server.", :true, :false)
  ##end

  #validate do
  #  if self[:address] and (self[:address].match(Resolv::IPv6::Regex) || self[:address].match(Resolv::IPv4::Regex))
  #    if self[:translation_ip_address] or self[:translation_mask] or self[:resolve_retry] or self[:ipv6_domain]
  #      raise ArgumentError, "If address is an IP address, cannot configure any of translation_ip_address, translation_mask, ipv6_domain, or resolve_retry when address is an IP address."
  #    end
  #  end
  #end

  validate do
    if self[:clear_text_port] and ! [:DTLS, :SSL, :SSL_TCP].include? self[:protocol].to_sym
      fail ArgumentError, "clear_text_port may only be set for DTLS, SSL, and SSL_TCP protocols."
    end
  end
  autorequire(:netscaler_server) do
    self[:server_name] if server = self[:server_name]
  end
end
