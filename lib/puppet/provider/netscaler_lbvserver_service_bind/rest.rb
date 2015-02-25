require 'puppet/provider/netscaler_binding'

Puppet::Type.type(:netscaler_lbvserver_service_bind).provide(:rest, parent: Puppet::Provider::NetscalerBinding) do
  def netscaler_api_type
    "lbvserver_service_binding"
  end

  def self.instances
    instances = []
    lbvservers = Puppet::Provider::Netscaler.call("/config/lbvserver")
    return [] if lbvservers.nil?

    lbvservers.each do |lbvserver|
      binds = Puppet::Provider::Netscaler.call("/config/lbvserver_service_binding/#{lbvserver['name']}") || []
      binds.each do |bind|
        instances << new(
          :ensure => :present,
          :name   => "#{bind['name']}/#{bind['servicename']}",
          :weight => bind['weight'],
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
    message[:name], message[:servicename] = message[:name].split('/')

    message
  end

  def destroy
    toname, fromname = resource.name.split('/').map { |n| URI.escape(n) }
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{toname}",{'args'=>"servicename:#{fromname}"})
    @property_hash.clear

    return result
  end
end
