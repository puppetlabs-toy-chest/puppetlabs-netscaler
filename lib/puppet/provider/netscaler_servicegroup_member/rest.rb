require 'puppet/provider/netscaler_binding'

Puppet::Type.type(:netscaler_servicegroup_member).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def netscaler_api_type
    "servicegroup_servicegroupmember_binding"
  end

  def self.instances
    instances = []
    servicegroups = Puppet::Provider::Netscaler.call("/config/servicegroup")
    return [] if servicegroups.nil?

    servicegroups.each do |servicegroup|
      binds = Puppet::Provider::Netscaler.call("/config/servicegroup_servicegroupmember_binding/#{servicegroup['servicegroupname']}") || []
      binds.each do |bind|
        instances << new(
          :ensure    => :present,
          :name      => "#{bind['servicegroupname']}/#{bind['servername']}:#{bind['port']}",
          :weight    => bind['weight'],
          :server_id => bind['serverid'],
          :hash_id   => bind['hashid'],
          :state     => bind['state'],
        )
      end
    end

    instances
  end

  mk_resource_methods

  # Same as Puppet::Provider::NetscalerBinding
  def destroy
    toname, fromname_port = resource.name.split('/')
    fromname, port = fromname_port.split(':')
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{toname}",{'args'=>"servername:#{fromname},port:#{port}"})
    @property_hash.clear

    return result
  end

  def immutable_properties
    [
      :state,
    ]
  end

  def property_to_rest_mapping
    {
    }
  end

  def per_provider_munge(message)
    message[:servicegroupname], server_port = message[:name].split('/')
    message[:servername], message[:port] = server_port.split(':')
    message.delete(:name)

    message
  end
end
