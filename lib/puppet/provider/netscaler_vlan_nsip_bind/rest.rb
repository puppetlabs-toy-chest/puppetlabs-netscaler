require 'puppet/provider/netscaler_binding'

Puppet::Type.type(:netscaler_vlan_nsip_bind).provide(:rest, parent: Puppet::Provider::NetscalerBinding) do
  def netscaler_api_type
    "vlan_nsip_binding"
  end

  def self.instances
    instances = []
    services = Puppet::Provider::Netscaler.call("/config/vlan")
    return [] if services.nil?

    services.each do |service|
      binds = Puppet::Provider::Netscaler.call("/config/vlan_nsip_binding/#{service['name']}") || []
      require'pry';binding.pry
      binds.each do |bind|
        instances << new(
          :ensure  => :present,
          :name    => "#{bind['id']}/#{bind['ipaddress']}",
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

  def per_provider_munge(message)
    message[:id], message[:ipaddress] = message[:name].split('/')

    message
  end

  def destroy
    toname, fromname = resource.name.split('/').map { |n| URI.escape(n) }
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{toname}",{'args'=>"ipaddress:#{fromname}"})
    @property_hash.clear

    return result
  end
end

