require 'puppet/parameter/netscaler_name'
require 'puppet/property/netscaler_truthy'

Puppet::Type.newtype(:netscaler_vlan) do
  @doc = 'Manage basic netscaler network IP objects.'

  apply_to_device
  ensurable

  newparam(:vlan_id, :namevar => true) do #<Double>
    desc "A positive integer that uniquely identifies a VLAN.
Minimum value = 1
Maximum value = 4094"
  end

  newproperty(:alias_name) do #<String>
    desc "A name for the VLAN. Must begin with a letter, a number, or the underscore symbol, and can consist of from 1 to 31 letters, numbers, and the hyphen (-), period (.) pound (#), space ( ), at sign (@), equals (=), colon (:), and underscore (_) characters. You should choose a name that helps identify the VLAN. However, you cannot perform any VLAN operation by specifying this name instead of the VLAN ID.
Maximum length = 31"
  end

  newproperty(:ipv6_dynamic_routing, :parent => Puppet::Property::NetscalerTruthy) do #<String>
    truthy_property("Enable all IPv6 dynamic routing protocols on this VLAN. Note: For the ENABLED setting to work, you must configure IPv6 dynamic routing protocols from the VTYSH command line.
Default value: DISABLED
Possible values = ENABLED, DISABLED","ENABLED","DISABLED")
  end

  newproperty(:maximum_transmission_unit) do #<Double>
    desc "Specifies the maximum transmission unit (MTU), in bytes. The MTU is the largest packet size, excluding 14 bytes of ethernet header and 4 bytes of crc, that can be transmitted and received over this VLAN.
Default value: 0
Minimum value = 500
Maximum value = 9216"
  end
end
