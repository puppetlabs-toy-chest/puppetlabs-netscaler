require 'puppet/property/netscaler_truthy'

Puppet::Type.newtype(:netscaler_servicegroup_member) do
  @doc = 'Manage a member of a servicegroup.'

  apply_to_device
  ensurable

  newparam(:name, :namevar => true) do
    desc "servicegroup_name/server_name:server_port"
    validate do |value|
      # This should validate that port is a port
    end
  end

  newproperty(:weight) do
    desc "Weight to assign to the servers in the service group. Specifies the capacity of the servers relative to the other servers in the load balancing configuration. The higher the weight, the higher the percentage of requests sent to the service.

    Min = 1
    Max = 100"
    newvalues(/^\d+$/)
    munge do |value|
      Integer(value)
    end
  end

  newproperty(:state, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property('The configured state (enable/disable) of the service group.','ENABLED','DISABLED')
  end

  autorequire(:netscaler_servicegroup) do
    self[:name].split('/')[0]
  end
  autorequire(:netscaler_server) do
    self[:name].split('/')[1].split(':')[0]
  end
end
