require_relative('../../puppet/property/netscaler_truthy')

Puppet::Type.newtype(:netscaler_rewriteglobal) do
  @doc = 'Activates the specified rewrite policy for all requests sent to the NetScaler appliance.'

  apply_to_device
  ensurable

  newparam(:name, :namevar => true) do
    desc "Name of the rewrite policy."
  end

  newproperty(:connection_type) do
    desc "Type of invocation when invoking a vserver. Available settings function as follows: 
      * Request - Forward the request to the specified request virtual server. 
      * Response - Forward the response to the specified response virtual server.
      This property is not applicable for use in conjunction with invoking a Policy Label." 
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

  autorequire(:netscaler_rewritepolicy) do
    self[:name]
  end

  autorequire(:netscaler_lbvserver) do
    self[:invoke_vserver_label]
  end

  autorequire(:netscaler_csvserver) do
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
      fail "Only one of invoke_policy_label or invoke_vserver_label may be specified per bind."
    end

    if [
      self[:invoke_policy_label],
      self[:connection_type],
    ].compact.length > 1
      fail "connection_type cannot be set when invoking a policy label."
    end

    if [
      self[:invoke_vserver_label],
      self[:connection_type],
    ].compact.length == 1
      fail "When invoking a vserver, a connection type must be specified, and vice versa."
    end
  end
end
