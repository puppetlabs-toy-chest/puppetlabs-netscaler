require 'puppet/property/netscaler_truthy'

Puppet::Type.newtype(:netscaler_servicegroup_lbmonitor_binding) do
  @doc = 'Manage a binding between a servicegroup and a loadbalancing monitor.'

  apply_to_device
  ensurable

  newparam(:name, :namevar => true) do
    desc "servicegroup_name/lbmonitor_name"
  end

  newproperty(:weight) do
    desc "Weight to assign to the monitor-servicegroup binding. When a monitor is UP, the weight assigned to its binding with the servicegroup determines how much the monitor contributes toward keeping the health of the servicegroup above the value configured for the Monitor Threshold parameter.

    Min = 1
    Max = 100"
    newvalues(/^\d+$/)
    munge do |value|
      Integer(value)
    end
  end

  newproperty(:state, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property('The configured state (enable/disable) of the bound monitor.','ENABLED','DISABLED')
  end

  newproperty(:passive, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property('Indicates if the monitor is passive. A passive monitor does not remove servicegroup from LB decision when the threshold is breached.','true','false')

    munge do |value|
      value.downcase == 'true'
    end
  end

  autorequire(:netscaler_servicegroup) do
    self[:name].split('/')[0]
  end
  autorequire(:netscaler_lbmonitor) do
    self[:name].split('/')[1]
  end
end
