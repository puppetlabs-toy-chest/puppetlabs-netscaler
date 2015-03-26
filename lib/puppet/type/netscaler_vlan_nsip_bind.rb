require 'puppet/property/netscaler_truthy'

Puppet::Type.newtype(:netscaler_vlan_nsip_bind) do
  @doc = 'Manage a binding between a vlan and a netscaler IP address.'

  apply_to_device
  ensurable

  newparam(:name, :namevar => true) do
    desc "vlan_id/ip_address"
  end

  newproperty(:netmask) do
    desc "Subnet mask for the network address defined for this VLAN."
  end

  newproperty(:td) do
    desc "Integer value that uniquely identifies the traffic domain in which you want to configure the entity. If you do not specify an ID, the entity becomes part of the default traffic domain, which has an ID of 0.
Minimum value = 0
Maximum value = 4094"
  end

  autorequire(:netscaler_vlan) do
    self[:name].split('/')[0]
  end

  autorequire(:netscaler_nsip) do
    self[:name].split('/')[1]
  end
end
