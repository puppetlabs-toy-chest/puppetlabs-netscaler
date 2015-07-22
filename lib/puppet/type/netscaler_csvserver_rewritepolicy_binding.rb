require 'puppet/property/netscaler_truthy'

Puppet::Type.newtype(:netscaler_csvserver_rewritepolicy_binding) do
  @doc = 'Manage a binding between a content switching vserver and a rewrite policy.'

  apply_to_device
  ensurable

  newparam(:name, :namevar => true) do
    desc "csvserver_name/policy_name"
  end

  newproperty(:choose_type) do
    desc "Type of invocation when invoking a vserver. Available settings functions are Request and Response. This property is not applicable for use in conjunction with invoking a Policy Label." 

    validate do |value|
      if ! [:Request,:Response,].any?{ |s| s.to_s.eql? value }
        fail ArgumentError, "Valid options: Request, Response"
      end
    end

    munge do |value|
      value = value.upcase
      case value
        when 'REQUEST'
          value = 'Request'
        when 'RESPONSE'
          value = 'Response'
      end
      value
    end
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
    desc "Label of csvserver to invoke if the bound policy evaluates to true."
  end

  autorequire(:netscaler_csvserver) do
    [self[:name].split('/')[0],self[:invoke_vserver_label]]
  end

  autorequire(:netscaler_rewritepolicy) do
    self[:name].split('/')[1]
  end

  autorequire(:netscaler_lbvserver) do
    self[:invoke_vserver_label]
  end

  autorequire(:netscaler_rewritepolicylabel) do
    self[:invoke_policy_label]
  end

  validate do
    if [
      self[:invoke_policy_label],
      self[:invoke_vserver_label],
    ].compact.length > 1
      fail "Only one of invoke_policy_label or invoke_vserver_label may be specified per binding."
    end
  end

  validate do
    if !self[:choose_type] and !(self[:ensure] == :absent)
      fail "choose_type must be specified."
    end
  end
end
