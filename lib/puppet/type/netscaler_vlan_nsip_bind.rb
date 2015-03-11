require 'puppet/property/netscaler_truthy'

Puppet::Type.newtype(:netscaler_vlan_nsip_bind) do
  @doc = 'Manage a binding between a vlan and a netscaler IP address.'

  apply_to_device
  ensurable

  newparam(:name, :namevar => true) do
    desc "vlan_id/ip_address"
  end

  autorequire(:netscaler_vlan) do
    self[:name].split('/')[0]
  end
  autorequire(:netscaler_nsip) do
    self[:name].split('/')[1]
  end
end
