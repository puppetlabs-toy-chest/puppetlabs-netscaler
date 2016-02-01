require_relative('../../puppet/parameter/netscaler_name')
require_relative('../../puppet/property/netscaler_truthy')

Puppet::Type.newtype(:netscaler_nsip) do
  @doc = 'Manage basic netscaler network IP objects.'

  apply_to_device
  ensurable

  newparam(:ip_address, :namevar => true) do #<String>
    desc "IPv4 address to create on the NetScaler appliance. Cannot be changed after the resource is created.
Minimum length = 1"
  end

  newproperty(:netmask) do #<String>
    desc "Subnet mask associated with the IP address. Required."
  end

  newproperty(:ip_type) do #<String>
    desc "Type of the IP address to create on the NetScaler appliance. Cannot be changed after the IP address is created. The following are the different types of NetScaler owned IP addresses: * A Subnet IP (SNIP) address is used by the NetScaler ADC to communicate with the servers. The NetScaler also uses the subnet IP address when generating its own packets, such as packets related to dynamic routing protocols, or to send monitor probes to check the health of the servers. * A Virtual IP (VIP) address is the IP address associated with a virtual server. It is the IP address to which clients connect. An appliance managing a wide range of traffic may have many VIPs configured. Some of the attributes of the VIP address are customized to meet the requirements of the virtual server. * A GSLB site IP (GSLBIP) address is associated with a GSLB site. It is not mandatory to specify a GSLBIP address when you initially configure the NetScaler appliance. A GSLBIP address is used only when you create a GSLB site. * A Cluster IP (CLIP) address is the management address of the cluster. All cluster configurations must be performed by accessing the cluster through this IP address.
Default value: SNIP
Possible values = SNIP, VIP, NSIP, GSLBsiteIP, CLIP"
  end

  newproperty(:virtual_router_id) do #<Double>
    desc "A positive integer that uniquely identifies a VMAC address for binding to this VIP address. This binding is used to set up NetScaler appliances in an active-active configuration using VRRP.
Minimum value = 1
Maximum value = 255"
  end

  newproperty(:icmp_response) do #<String>
    desc "Respond to ICMP requests for a Virtual IP (VIP) address on the basis of the states of the virtual servers associated with that VIP. Available settings function as follows: * NONE - The NetScaler appliance responds to any ICMP request for the VIP address, irrespective of the states of the virtual servers associated with the address. * ONE VSERVER - The NetScaler appliance responds to any ICMP request for the VIP address if at least one of the associated virtual servers is in UP state. * ALL VSERVER - The NetScaler appliance responds to any ICMP request for the VIP address if all of the associated virtual servers are in UP state. * VSVR_CNTRLD - The behavior depends on the ICMP VSERVER RESPONSE setting on all the associated virtual servers. The following settings can be made for the ICMP VSERVER RESPONSE parameter on a virtual server: * If you set ICMP VSERVER RESPONSE to PASSIVE on all virtual servers, NetScaler always responds. * If you set ICMP VSERVER RESPONSE to ACTIVE on all virtual servers, NetScaler responds if even one virtual server is UP. * When you set ICMP VSERVER RESPONSE to ACTIVE on some and PASSIVE on others, NetScaler responds if even one virtual server set to ACTIVE is UP.
Default value: 5
Possible values = NONE, ONE_VSERVER, ALL_VSERVERS, VSVR_CNTRLD"
  end

  newproperty(:arp_response) do #<String>
    desc "Respond to ARP requests for a Virtual IP (VIP) address on the basis of the states of the virtual servers associated with that VIP. Available settings function as follows: * NONE - The NetScaler appliance responds to any ARP request for the VIP address, irrespective of the states of the virtual servers associated with the address. * ONE VSERVER - The NetScaler appliance responds to any ARP request for the VIP address if at least one of the associated virtual servers is in UP state. * ALL VSERVER - The NetScaler appliance responds to any ARP request for the VIP address if all of the associated virtual servers are in UP state.
Default value: 5
Possible values = NONE, ONE_VSERVER, ALL_VSERVERS"
  end

  newproperty(:traffic_domain) do #<Double>
    desc "Integer value that uniquely identifies the traffic domain in which you want to configure the entity. If you do not specify an ID, the entity becomes part of the default traffic domain, which has an ID of 0.
Minimum value = 0
Maximum value = 4094"
  end

  newproperty(:state, :parent => Puppet::Property::NetscalerTruthy) do #<String>
    truthy_property("Enable or disable the IP address.
Default value: ENABLED
Possible values = ENABLED, DISABLED","ENABLED","DISABLED")
  end

  newproperty(:arp, :parent => Puppet::Property::NetscalerTruthy) do #<String>
    truthy_property("Respond to ARP requests for this IP address.
Default value: ENABLED
Possible values = ENABLED, DISABLED","ENABLED","DISABLED")
  end

  newproperty(:icmp, :parent => Puppet::Property::NetscalerTruthy) do #<String>
    truthy_property("Respond to ICMP requests for this IP address.
Default value: ENABLED
Possible values = ENABLED, DISABLED","ENABLED","DISABLED")
  end

  newproperty(:virtual_server, :parent => Puppet::Property::NetscalerTruthy) do #<String>
    truthy_property("Use this option to set (enable or disable) the virtual server attribute for this IP address.
Default value: ENABLED
Possible values = ENABLED, DISABLED","ENABLED","DISABLED")
  end

  newproperty(:dynamic_routing, :parent => Puppet::Property::NetscalerTruthy) do #<String>
    truthy_property("Allow dynamic routing on this IP address. Specific to Subnet IP (SNIP) address.
Default value: DISABLED
Possible values = ENABLED, DISABLED","ENABLED","DISABLED")
  end

  newproperty(:host_route, :parent => Puppet::Property::NetscalerTruthy) do #<String>
    truthy_property("Advertise a route for the VIP address using the dynamic routing protocols running on the NetScaler appliance.
Possible values = ENABLED, DISABLED","ENABLED","DISABLED")
  end

  newproperty(:host_route_gateway_ip) do #<String>
    desc "IP address of the gateway of the route for this VIP address.
Default value: -1"
  end

  newproperty(:host_route_metric) do #<Integer>
    desc "Integer value to add to or subtract from the cost of the route advertised for the VIP address.
Minimum value = -16777215"
  end

  newproperty(:ospf_lsa_type) do #<String>
    desc "Type of LSAs to be used by the OSPF protocol, running on the NetScaler appliance, for advertising the route for this VIP address.
Default value: DISABLED
Possible values = TYPE1, TYPE5"
  end

  newproperty(:ospf_area) do #<Double>
    desc "ID of the area in which the type1 link-state advertisements (LSAs) are to be advertised for this virtual IP (VIP) address by the OSPF protocol running on the NetScaler appliance. When this parameter is not set, the VIP is advertised on all areas.
Default value: -1
Minimum value = 0
Maximum value = 4294967294LU"
  end

  newproperty(:virtual_server_rhi_level) do #<String>
    desc "Advertise the route for the Virtual IP (VIP) address on the basis of the state of the virtual servers associated with that VIP. * NONE - Advertise the route for the VIP address, regardless of the state of the virtual servers associated with the address. * ONE VSERVER - Advertise the route for the VIP address if at least one of the associated virtual servers is in UP state. * ALL VSERVER - Advertise the route for the VIP address if all of the associated virtual servers are in UP state. * VSVR_CNTRLD - Advertise the route for the VIP address according to the RHIstate (RHI STATE) parameter setting on all the associated virtual servers of the VIP address along with their states. When Vserver RHI Level (RHI) parameter is set to VSVR_CNTRLD, the following are different RHI behaviors for the VIP address on the basis of RHIstate (RHI STATE) settings on the virtual servers associated with the VIP address: * If you set RHI STATE to PASSIVE on all virtual servers, the NetScaler ADC always advertises the route for the VIP address. * If you set RHI STATE to ACTIVE on all virtual servers, the NetScaler ADC advertises the route for the VIP address if at least one of the associated virtual servers is in UP state. *If you set RHI STATE to ACTIVE on some and PASSIVE on others, the NetScaler ADC advertises the route for the VIP address if at least one of the associated virtual servers, whose RHI STATE set to ACTIVE, is in UP state.
Default value: ONE_VSERVER
Possible values = ONE_VSERVER, ALL_VSERVERS, NONE, VSVR_CNTRLD"
  end

  newproperty(:virtual_server_rhi_mode) do #<String>
    desc "Advertise the route for the Virtual IP (VIP) address using dynamic routing protocols or using RISE * DYNMAIC_ROUTING - Advertise the route for the VIP address using dynamic routing protocols (default) * RISE - Advertise the route for the VIP address using RISE.
Default value: DYNAMIC_ROUTING
Possible values = DYNAMIC_ROUTING, RISE"
  end

  newproperty(:allow_telnet, :parent => Puppet::Property::NetscalerTruthy) do #<String>
    truthy_property("Allow Telnet access to this IP address.
Default value: ENABLED
Possible values = ENABLED, DISABLED","ENABLED","DISABLED")
  end

  newproperty(:allow_ftp, :parent => Puppet::Property::NetscalerTruthy) do #<String>
    truthy_property("Allow File Transfer Protocol (FTP) access to this IP address.
Default value: ENABLED
Possible values = ENABLED, DISABLED","ENABLED","DISABLED")
  end

  newproperty(:allow_ssh, :parent => Puppet::Property::NetscalerTruthy) do #<String>
    truthy_property("Allow secure shell (SSH) access to this IP address.
Default value: ENABLED
Possible values = ENABLED, DISABLED","ENABLED","DISABLED")
  end

  newproperty(:allow_snmp, :parent => Puppet::Property::NetscalerTruthy) do #<String>
    truthy_property("Allow Simple Network Management Protocol (SNMP) access to this IP address.
Default value: ENABLED
Possible values = ENABLED, DISABLED","ENABLED","DISABLED")
  end

  newproperty(:allow_gui) do #<String>
    desc "Allow graphical user interface (GUI) access to this IP address.
Default value: ENABLED
Possible values = ENABLED, SECUREONLY, DISABLED"
  end

  newproperty(:allow_management_access, :parent => Puppet::Property::NetscalerTruthy) do #<String>
    truthy_property("Allow access to management applications on this IP address.
Default value: DISABLED
Possible values = ENABLED, DISABLED","ENABLED","DISABLED")
  end

  newproperty(:secure_access_only, :parent => Puppet::Property::NetscalerTruthy) do #<String>
    truthy_property("Block access to nonmanagement applications on this IP. This option is applicable for MIPs, SNIPs, and NSIP, and is disabled by default. Nonmanagement applications can run on the underlying NetScaler Free BSD operating system.
Default value: DISABLED
Possible values = ENABLED, DISABLED","ENABLED","DISABLED")
  end

#  newproperty(:ospf, :parent => Puppet::Property::NetscalerTruthy) do #<String>
#    truthy_property("Use this option to enable or disable OSPF on this IP address for the entity.
#Default value: DISABLED
#Possible values = ENABLED, DISABLED"
#  end
#
#  newproperty(:bgp, :parent => Puppet::Property::NetscalerTruthy) do #<String>
#    truthy_property("Use this option to enable or disable BGP on this IP address for the entity.
#Default value: DISABLED
#Possible values = ENABLED, DISABLED"
#  end
#
#  newproperty(:rip, :parent => Puppet::Property::NetscalerTruthy) do #<String>
#    truthy_property("Use this option to enable or disable RIP on this IP address for the entity.
#Default value: DISABLED
#Possible values = ENABLED, DISABLED"
#  end
#
#  newproperty(:ownernode) do #<Double>
#    desc "The owner node in a Cluster for this IP address. Owner node can vary from 0 to 31. If ownernode is not specified then the IP is treated as Striped IP.
#Default value: 255"
#  end
end
