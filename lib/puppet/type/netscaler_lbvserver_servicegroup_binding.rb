require_relative('../../puppet/property/netscaler_truthy')

Puppet::Type.newtype(:netscaler_lbvserver_servicegroup_binding) do
  @doc = 'Manage a binding between a loadbalancing vserver and a servicegroup.'

  apply_to_device
  ensurable

  newparam(:name, :namevar => true) do
    desc "lbvserver_name/servicegroup_name"
  end

  autorequire(:netscaler_lbvserver) do
    self[:name].split('/')[0]
  end
  autorequire(:netscaler_servicegroup) do
    self[:name].split('/')[1]
  end
end
