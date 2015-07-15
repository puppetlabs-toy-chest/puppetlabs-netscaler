require 'puppet/provider/netscaler_binding'

Puppet::Type.type(:netscaler_vlan_nsip_binding).provide(:rest, {:parent => Puppet::Provider::NetscalerBinding}) do
  def netscaler_api_type
    "vlan_nsip_binding"
  end

  def self.instances
    instances = []
    services = Puppet::Provider::Netscaler.call("/config/vlan")
    return [] if services.nil?

    services.each do |service|
      binds = Puppet::Provider::Netscaler.call("/config/vlan_nsip_binding/#{service['id']}") || []
      binds.each do |bind|
        instances << new(
          :ensure  => :present,
          :name    => "#{bind['id']}/#{bind['ipaddress']}",
          :netmask => bind['netmask'],
          :td      => bind['td'],
        )
      end
    end

    instances
  end

  mk_resource_methods

  def property_to_rest_mapping
    {
    }
  end

  def immutable_properties
    [
      :netmask,
      :td,
    ]
  end

  def per_provider_munge(message)
    message[:id], message[:ipaddress] = message[:name].split('/')
    message.delete(:name)

    message
  end

  def destroy
    toname, fromname = resource.name.split('/').map { |n| URI.escape(n) }
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{toname}",{'args'=>"ipaddress:#{fromname},td:#{@property_hash[:td]},netmask:#{@property_hash[:netmask]}"})
    @property_hash.clear

    return result
  end
end

