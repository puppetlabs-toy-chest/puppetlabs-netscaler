require 'puppet/provider/netscaler_binding'

Puppet::Type.type(:netscaler_csvserver_lbvserver_binding).provide(:rest, parent: Puppet::Provider::NetscalerBinding) do
  def netscaler_api_type
    "csvserver_lbvserver_binding"
  end

  def self.instances
    instances = []
    csvservers = Puppet::Provider::Netscaler.call("/config/csvserver")
    return [] if csvservers.nil?

    csvservers.each do |csvserver|
      binds = Puppet::Provider::Netscaler.call("/config/csvserver_lbvserver_binding/#{csvserver['name']}") || []
      binds.each do |bind|
        instances << new(
          :ensure           => :present,
          :name             => "#{bind['name']}/#{bind['lbvserver']}",
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

  def destroy
    csvserver, lbvserver = resource.name.split('/')
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{csvserver}", {'args'=>"lbvserver:#{lbvserver}"})
    @property_hash.clear

    return result
  end

  def per_provider_munge(message)
    message[:name], message[:lbvserver] = message[:name].split('/')

    message
  end
end
