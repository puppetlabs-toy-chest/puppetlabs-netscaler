require 'puppet/parameter/netscaler_name'
require 'puppet/property/netscaler_traffic_domain'
require 'puppet/property/netscaler_truthy'

Puppet::Type.newtype(:netscaler_route) do
  @doc = 'Configuration for route resource. It is worth noting, even though the api documentation allows you to update a route, the ui or api will not let you'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)
    desc "IPv4 network address, netmask and gateway. In the following format network/netmask:gateway eg 8.8.8.0/255.255.255.0:null"
  #XXX Validate with the below
  #ensure: change from absent to present failed: Could not set 'present' on ensure: REST failure: HTTP status code 400 detected.  Body of failure is: { "errorcode": 1075, "message": "Invalid name; names must begin with an alphanumeric character or underscore and must contain only alphanumerics, '_', '#', '.', ' ', ':', '@', '=' or '-' [name, hunner's website]", "severity": "ERROR" } at 55:/etc/puppetlabs/puppet/environments/produc

  newproperty(:td) do
    desc "Integer value that uniquely identifies the traffic domain in which you want to configure the entity. If you do not specify an ID, the entity becomes part of the default traffic domain, which has an ID of 0.
Minimum value = 0
Maximum value = 4094"
  end

  newproperty(:distance) do
    desc "Administrative distance of this route, which determines the preference of this route over other routes, with same destination, from different routing protocols. A lower value is preferred.
Default value: 1
Minimum value = 0
Maximum value = 255"
  end

  newproperty(:cost1) do
    desc "Positive integer used by the routing algorithms to determine preference for using this route. The lower the cost, the higher the preference.
Minimum value = 0
Maximum value = 65535"
  end

  newproperty(:weight) do
    desc "Positive integer used by the routing algorithms to determine preference for this route over others of equal cost. The lower the weight, the higher the preference.
Default value: 1
Minimum value = 1
Maximum value = 65535"
  end

  newproperty(:advertise, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Advertise this route. Possible values = DISABLED, ENABLED", "DISABLED", "ENABLED")
  end

  newproperty(:protocol) do
    desc "Routing protocol used for advertising this route.
Default value: ADV_ROUTE_FLAGS
Possible values = OSPF, ISIS, RIP, BGP"
    validate do |value|
      if ! [
        :ADV_ROUTE_FLAGS,
        :OSPF,
        :ISIS,
        :RIP,
        :BGP,
      ].any?{ |s| s.casecmp(value.to_sym) == 0 }
        fail ArgumentError, "Valid options: ADV_ROUTE_FLAGS, OSPF, ISIS, RIP, BGP"
      end 
    end

    munge(&:downcase)
  end

  newproperty(:msr, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Monitor this route using a monitor of type ARP or PING. Possible values = DISABLED, ENABLED", "DISABLED", "ENABLED")
  end

  newproperty(:monitor) do
    desc "Name of the monitor, of type ARP or PING, configured on the NetScaler appliance to monitor this route. Minimum length = 1"
  end
end
