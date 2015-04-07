require 'puppet/property/netscaler_truthy'

Puppet::Type.newtype(:netscaler_csvserver_lbvserver_binding) do
  @doc = 'Manage a binding between a content switching vserver and a content switching poliicy.'

  apply_to_device
  ensurable

  newparam(:name, :namevar => true) do
    desc "csvserver_name/lbvserver_name"
  end

end
