require 'puppet/property/netscaler_truthy'

Puppet::Type.newtype(:netscaler_lbvserver_service_bind) do
  @doc = 'Manage a binding between a loadbalancing vserver and a service.'

  apply_to_device
  ensurable

  newparam(:name, :namevar => true) do
    desc "lbvserver_name/service_name"
  end

  newproperty(:weight) do
    desc "Weight to assign to the specified service.

Min = 1
Max = 100"
    newvalues(/^\d+$/)
    munge do |value|
      Integer(value)
    end
  end

  autorequire(:netscaler_lbvserver) do
    self[:name].split('/')[0]
  end
  autorequire(:netscaler_service) do
    self[:name].split('/')[1]
  end
end
