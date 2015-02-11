require 'puppet/property/netscaler_truthy'

Puppet::Type.newtype(:netscaler_rewriteglobal) do
  @doc = 'Activates the specified rewrite policy for all requests sent to the NetScaler appliance.'

  apply_to_device
  ensurable

  newparam(:name, :namevar => true) do
    desc "Name of the rewrite policy."
  end

  newproperty(:type) do
    desc "The bindpoint to which to policy is bound. Valid options: REQ_OVERRIDE, REQ_DEFAULT, RES_OVERRIDE, RES_DEFAULT, OTHERTCP_REQ_OVERRIDE, OTHERTCP_REQ_DEFAULT, OTHERTCP_RES_OVERRIDE, OTHERTCP_RES_DEFAULT, SIPUDP_REQ_OVERRIDE, SIPUDP_REQ_DEFAULT, SIPUDP_RES_OVERRIDE, SIPUDP_RES_DEFAULT."

    validate do |value|
      if ! [:REQ_OVERRIDE, :REQ_DEFAULT, :RES_OVERRIDE, :RES_DEFAULT, :OTHERTCP_REQ_OVERRIDE, :OTHERTCP_REQ_DEFAULT, :OTHERTCP_RES_OVERRIDE, :OTHERTCP_RES_DEFAULT, :SIPUDP_REQ_OVERRIDE, :SIPUDP_REQ_DEFAULT, :SIPUDP_RES_OVERRIDE, :SIPUDP_RES_DEFAULT].include? value.to_sym
        fail ArgumentError, "Valid options: REQ_OVERRIDE, REQ_DEFAULT, RES_OVERRIDE, RES_DEFAULT, OTHERTCP_REQ_OVERRIDE, OTHERTCP_REQ_DEFAULT, OTHERTCP_RES_OVERRIDE, OTHERTCP_RES_DEFAULT, SIPUDP_REQ_OVERRIDE, SIPUDP_REQ_DEFAULT, SIPUDP_RES_OVERRIDE, SIPUDP_RES_DEFAULT"
      end
    end

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

  newproperty(:gotopriorityexpression) do
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

  validate do
    if [
      self[:invoke_policy_label],
      self[:invoke_vserver_label],
    ].compact.length > 1
      err "Only one of invoke_policy_label or invoke_vserver_label may be specified per bind."
    end
  end

end