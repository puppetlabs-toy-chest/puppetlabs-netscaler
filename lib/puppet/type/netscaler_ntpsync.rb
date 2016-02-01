require_relative('../../puppet/property/netscaler_truthy')

Puppet::Type.newtype(:netscaler_ntpsync) do
  @doc = 'Manage netscaler NTP sync setting.'

  apply_to_device
  ensurable do
    defaultto :present
    newvalue(:present) do
      provider.set_state(resource[:state])
    end
    newvalue(:absent) do
      provider.set_state('DISABLED')
    end
  end

  newparam(:state, :parent => Puppet::Property::NetscalerTruthy, :namevar => true) do
    truthy_property("NTP status.
    Possible values = ENABLED, DISABLED","ENABLED","DISABLED")
  end
end
