require 'puppet/property/netscaler_truthy'

Puppet::Type.newtype(:netscaler_responderglobal) do
  @doc = 'Activates the specified responder policy for all requests sent to the NetScaler appliance.'

  apply_to_device
  ensurable

  newparam(:name, :namevar => true) do
    desc "Name of the responder policy."
  end

  newproperty(:priority) do
    desc "Specifies the priority of the policy.

    Min = 1
    Max = 2147483647"
    newvalues(/^\d+$/)
    munge do |value|
      Integer(value)
    end
  end

  newproperty(:goto_expression) do
    desc "Expression specifying the priority of the next policy which will get evaluated if the current policy rule evaluates to TRUE."
  end

  newproperty(:invoke_policy_label) do
    desc "Label of policy to invoke if the bound policy evaluates to true."
  end

  newproperty(:invoke_vserver_label) do
    desc "Label of lbvserver to invoke if the bound policy evaluates to true."
  end

 validate do
    if [
      self[:invoke_policy_label],
      self[:invoke_vserver_label],
    ].compact.length > 1
      err "Only one of invoke_policy_label, or invoke_vserver_label may be specified per bind."
    end
  end
end
