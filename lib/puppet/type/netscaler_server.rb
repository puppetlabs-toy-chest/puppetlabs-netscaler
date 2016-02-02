require_relative('../../puppet/parameter/netscaler_name')
require_relative('../../puppet/property/netscaler_truthy')
require_relative('../../puppet/property/netscaler_traffic_domain')

Puppet::Type.newtype(:netscaler_server) do
  @doc = 'Manage basic netscaler server objects. The NetScaler appliance supports two types of servers: IP address based servers and domain based servers.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)
  #XXX Validat with the below
  #ensure: change from absent to present failed: Could not set 'present' on ensure: REST failure: HTTP status code 400 detected.  Body of failure is: { "errorcode": 1075, "message": "Invalid name; names must begin with an alphanumeric character or underscore and must contain only alphanumerics, '_', '#', '.', ' ', ':', '@', '=' or '-' [name, hunner's website]", "severity": "ERROR" } at 55:/etc/puppetlabs/puppet/environments/produc

  newproperty(:address) do
    options = '[ipv4|ipv6|domain name]'
    desc "The domain name, IPv4 address, or IPv6 address of the server. When creating an IP address-based server, you can specify the name of the server instead of its IP address, when creating a service.
    Valid options: #{options}"
    validate do |value|
      unless value.match(Resolv::IPv6::Regex) || value.match(Resolv::IPv4::Regex) || value
        fail ArgumentError, "#{name} must be: #{options}."
      end
    end
  end

  newproperty(:traffic_domain_id, :parent => Puppet::Property::NetscalerTrafficDomain) do
  end

  newproperty(:comments) do
    desc "Any information about the server."
  end

  newproperty(:state, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("The state of the server.", "ENABLED", "DISABLED")
  end

  newparam(:disable_wait_time) do
    desc "Specifies a wait time when disabling a server object. The server object continues to handle established connections for the specified amount of time, but rejects new connections"
    newvalues(/\d+/)
  end

  newparam(:graceful_shutdown, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Indicates graceful shutdown of the server. System will wait for all outstanding connections to this server to be closed before disabling the server.", "YES", "NO")
  end

  newproperty(:translation_ip_address) do
    desc "IP address used to transform the server's DNS-resolved IP address."
    validate do |value|
      if ! value.match(Resolv::IPv4::Regex)
        raise ArgumentError, "translation_ip_address must be an IPv4 address."
      end 
    end
  end

  newproperty(:translation_mask) do
    desc "The netmask of the translation ip"
    validate do |value|
      if ! value.match(Resolv::IPv4::Regex)
        raise ArgumentError, "translation_mask must be an IPv4 address."
      end 
    end
  end

  newproperty(:resolve_retry) do
    desc "Time, in seconds, for which the NetScaler appliance must wait, after DNS resolution fails, before sending the next DNS query to resolve the domain name.

Default = 5
Min = 5
Max = 20939"
  end

  newproperty(:ipv6_domain, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Support IPv6 addressing mode. If you configure a server with the IPv6 addressing mode, you cannot use the server in the IPv4 addressing mode", "YES", "NO")
  end

  ## This is handled with the "state" property
  #newparam(:enable_after_creating, :parent => Puppet::Property::NetscalerTruthy) do
  #  truthy_property("Initial state of the server.", :true, :false)
  #end

  validate do
    if self[:address] and (self[:address].match(Resolv::IPv6::Regex) || self[:address].match(Resolv::IPv4::Regex))
      if self[:translation_ip_address] or self[:translation_mask] or self[:resolve_retry] or self[:ipv6_domain]
        raise ArgumentError, "If address is an IP address, cannot configure any of translation_ip_address, translation_mask, ipv6_domain, or resolve_retry when address is an IP address."
      end
    end
  end
end
