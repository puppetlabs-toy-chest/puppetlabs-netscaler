require 'puppet/property/netscaler_truthy'

Puppet::Type.newtype(:netscaler_responderglobal) do
  @doc = 'Activates the specified responder policy for all requests sent to the NetScaler appliance.'

  apply_to_device
  ensurable

  newproperty(:priority) do
    desc "Specifies the priority of the policy.

    Min = 1
    Max = 2147483647"
    newvalues(/^\d+$/)
    munge do |value|
      Integer(value)
    end
  end

  newproperty(:policyname) do
    desc "Name of the responder policy."
  end

  newproperty(:labelname) do
    desc "Name of the policy label to invoke. If the current policy evaluates to TRUE, the invoke parameter is set, and Label Type is policylabel."
  end

  newproperty(:gotopriorityexpression) do
    desc "Expression specifying the priority of the next policy which will get evaluated if the current policy rule evaluates to TRUE."
  end

  newproperty(:invoke, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property('If the current policy evaluates to TRUE, terminate evaluation of policies bound to the current policy label, and then forward the request to the specified virtual server or evaluate the specified policy label.','TRUE','FALSE')
  end

  newproperty(:type) do
    desc "Specifies the bind point whose policies you want to display. Available settings function as follows: REQ_OVERRIDE, REQ_DEFAULT, OVERRIDE, DEFAULT, OTHERTCP_REQ_OVERRIDE, OTHERTCP_REQ_DEFAULT, SIPUDP_REQ_OVERRIDE, SIPUDP_REQ_DEFAULT, MSSQL_REQ_OVERRIDE, MSSQL_REQ_DEFAULT, MYSQL_REQ_OVERRIDE, MYSQL_REQ_DEFAULT, NAT_REQ_OVERRIDE, NAT_REQ_DEFAULT, DIAMETER_REQ_OVERRIDE, DIAMETER_REQ_DEFAULT"
    validate do |value|
      if ! [
        :REQ_OVERRIDE,
        :REQ_DEFAULT,
        :OVERRIDE,
        :DEFAULT,
        :OTHERTCP_REQ_OVERRIDE,
        :OTHERTCP_REQ_DEFAULT,
        :IPUDP_REQ_OVERRIDE,
        :SIPUDP_REQ_DEFAULT,
        :MSSQL_REQ_OVERRIDE,
        :MSSQL_REQ_DEFAULT,
        :MYSQL_REQ_OVERRIDE,
        :MYSQL_REQ_DEFAULT,
        :NAT_REQ_OVERRIDE,
        :NAT_REQ_DEFAULT,
        :DIAMETER_REQ_OVERRIDE,
        :DIAMETER_REQ_DEFAULT,
      ].include? value.to_sym
        fail ArgumentError, "Valid Options: REQ_OVERRIDE, REQ_DEFAULT, OVERRIDE, DEFAULT, OTHERTCP_REQ_OVERRIDE, OTHERTCP_REQ_DEFAULT, SIPUDP_REQ_OVERRIDE, SIPUDP_REQ_DEFAULT, MSSQL_REQ_OVERRIDE, MSSQL_REQ_DEFAULT, MYSQL_REQ_OVERRIDE, MYSQL_REQ_DEFAULT, NAT_REQ_OVERRIDE, NAT_REQ_DEFAULT, DIAMETER_REQ_OVERRIDE, DIAMETER_REQ_DEFAULT"
      end
    end
  end

  newproperty(:labeltype) do
    desc "Type of invocation, Available settings function as follows: * vserver - Forward the request to the specified virtual server. * policylabel - Invoke the specified policy label.
Possible values = vserver, policylabel."
  end

end
