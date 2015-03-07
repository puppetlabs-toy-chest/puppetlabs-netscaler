require 'puppet/provider/netscaler'

Puppet::Type.type(:netscaler_nsip).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def netscaler_api_type
    "nsip"
  end

  def self.instances
    instances = []
    ips = Puppet::Provider::Netscaler.call('/config/nsip')
    return [] if ips.nil?

    ips.each do |ip|
      instances << new(
        :ensure                   => :present,
        :name                     => ip['ipaddress'],
        :netmask                  => ip['netmask'],
        :ip_type                  => ip['type'],
        :virtual_router_id        => ip['vrid'],
        :icmp_response            => ip['icmpresponse'],
        :arp_response             => ip['arpresponse'],
        :traffic_domain           => ip['td'],
        :state                    => ip['state'],
        :arp                      => ip['arp'],
        :icmp                     => ip['icmp'],
        :virtual_server           => ip['vserver'],
        :dynamic_routing          => ip['dynamicrouting'],
        :host_route               => ip['hostroute'],
        :host_route_gateway_ip    => ip['hostrtgw'],
        :host_route_metric        => ip['metric'],
        :ospf_lsa_type            => ip['ospflsatype'],
        :ospf_area                => ip['ospfarea'],
        :virtual_server_rhi_level => ip['vserverrhilevel'],
        :virtual_server_rhi_mode  => ip['vserverrhimode'],
        :allow_telnet             => ip['telnet'],
        :allow_ftp                => ip['ftp'],
        :allow_ssh                => ip['ssh'],
        :allow_snmp               => ip['snmp'],
        :allow_gui                => ip['gui'],
        :allow_management_access  => ip['mgmtaccess'],
        :secure_access_only       => ip['restrictaccess'],
      )
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :ip_type                  => :type,
      :virtual_router_id        => :vird,
      :traffic_domain           => :td,
      :virtual_server           => :vserver,
      :host_route_gateway_ip    => :hostrtgw,
      :host_route_metric        => :metric,
      :virtual_server_rhi_level => :vserverrhilevel,
      :virtual_server_rhi_mode  => :vserverrhimode,
      :allow_telnet             => :telnet,
      :allow_ftp                => :ftp,
      :allow_ssh                => :ssh,
      :allow_snmp               => :snmp,
      :allow_gui                => :gui,
      :allow_management_access  => :mgmtaccess,
      :secure_access_only       => :restrictaccess,
    }
  end

  def immutable_properties
    [
      :ip_address,
      :ip_type,
      :traffic_domain,
    ]
  end
  def per_provider_munge(message)
    message
  end
end
