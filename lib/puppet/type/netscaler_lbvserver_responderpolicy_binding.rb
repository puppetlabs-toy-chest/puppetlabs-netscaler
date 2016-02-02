require_relative('../../puppet/property/netscaler_truthy')

Puppet::Type.newtype(:netscaler_lbvserver_responderpolicy_binding) do
  @doc = 'Manage a binding between a loadbalancing vserver and a responder policy.'

  apply_to_device
  ensurable

  newparam(:name, :namevar => true) do
    desc "lbvserver_name/policy_name"
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

  newproperty(:invoke_policy_label) do
    desc "Label of policy to invoke if the bound policy evaluates to true."
  end

  newproperty(:invoke_vserver_label) do
    desc "Label of vserver to invoke if the bound policy evaluates to true."
  end

  autorequire(:netscaler_lbvserver) do
    [self[:name].split('/')[0], self[:invoke_vserver_label]]
  end

  autorequire(:netscaler_responderpolicy) do
    self[:name].split('/')[1]
  end

  autorequire(:netscaler_csvserver) do
    self[:invoke_vserver_label]
  end

  autorequire(:netscaler_responderpolicylabel) do
    self[:invoke_policy_label]
  end

  validate do
    if [
      self[:invoke_policy_label],
      self[:invoke_vserver_label],
    ].compact.length > 1
      err "Only one of invoke_policy_label or invoke_vserver_label may be specified per binding."
    end
  end
end
