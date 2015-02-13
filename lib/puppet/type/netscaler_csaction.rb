require 'puppet/parameter/netscaler_name'
require 'puppet/property/netscaler_truthy'

Puppet::Type.newtype(:netscaler_csaction) do
  @doc = 'Manage basic netscaler content switching action objects.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)

  newproperty(:target_lbvserver) do
    desc "Name of the load balancing virtual server to which the content is switched."
  end

  newproperty(:target_lb_expression) do
    desc "Information about this content switching action."
  end

  newproperty(:comments) do
    desc "Any information about the responder action."
  end

  autorequire(:netscaler_lbvserver) do
    self[:target_lbvserver]
  end
end
