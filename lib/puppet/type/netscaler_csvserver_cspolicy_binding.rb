require_relative('../../puppet/property/netscaler_truthy')

Puppet::Type.newtype(:netscaler_csvserver_cspolicy_binding) do
  @doc = 'Manage a binding between a content switching vserver and a content switching policy.'

  apply_to_device
  ensurable

  newparam(:name, :namevar => true) do
    desc "csvserver_name/policy_name"
  end

  newproperty(:priority) do
    desc "The priority of the policy binding.

Min = 1
Max = 2147483647"
    newvalues(/^\d+$/)
    munge do |value|
      Integer(value)
    end
  end

  newproperty(:goto_expression) do
    desc "Expression specifying the priority of the next policy which will get evaluated if the current policy rule evaluates to TRUE"
  end

  newproperty(:label_name) do
    desc "Label of policy to invoke if the bound policy evaluates to true."
  end

  newproperty(:target_lbvserver) do
    desc "The virtual server name to which content will be switched."
  end

  autorequire(:netscaler_csvserver) do
    self[:name].split('/')[0]
  end

  autorequire(:netscaler_cspolicy) do
    self[:name].split('/')[1]
  end

  autorequire(:netscaler_cspolicylabel) do
    self[:label_name]
  end

  autorequire(:netscaler_lbvserver) do
    self[:target_lbvserver]
  end
end
