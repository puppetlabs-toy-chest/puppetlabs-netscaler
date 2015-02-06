require 'puppet/property/netscaler_truthy'

Puppet::Type.newtype(:netscaler_csvserver_responderpolicy_bind) do
  @doc = 'Manage a binding between a content switching vserver and a responder policy.'

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

  newproperty(:invoke_policy_label) do
    desc "Label of policy to invoke if the bound policy evaluates to true."
  end

  newproperty(:invoke_lbvserver_label) do
    desc "Label of lbvserver to invoke if the bound policy evaluates to true."
  end

  newproperty(:invoke_csvserver_label) do
    desc "Label of csvserver to invoke if the bound policy evaluates to true."
  end

  autorequire(:netscaler_csvserver) do
    self[:name].split('/')[0]
  end
  autorequire(:netscaler_responderpolicy) do
    self[:name].split('/')[1]
  end

  validate do
    if [
      self[:invoke_policy_label],
      self[:invoke_lbvserver_label],
      self[:invoke_csvserver_label],
    ].compact.length > 1
      err "Only one of invoke_policy_label, invoke_csvserver_label, or invoke_csvserver_label may be specified per bind."
    end
  end
end
