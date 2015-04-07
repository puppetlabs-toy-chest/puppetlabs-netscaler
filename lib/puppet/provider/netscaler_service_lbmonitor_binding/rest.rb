require 'puppet/provider/netscaler_binding'

Puppet::Type.type(:netscaler_service_lbmonitor_binding).provide(:rest, parent: Puppet::Provider::NetscalerBinding) do
  def netscaler_api_type
    "service_lbmonitor_binding"
  end

  def self.instances
    instances = []
    services = Puppet::Provider::Netscaler.call("/config/service")
    return [] if services.nil?

    services.each do |service|
      binds = Puppet::Provider::Netscaler.call("/config/service_lbmonitor_binding/#{service['name']}") || []
      binds.each do |bind|
        instances << new(
          :ensure => :present,
          :name   => "#{bind['name']}/#{bind['monitor_name']}",
          :weight => bind['weight'],
          :state  => bind['monitor_state'] == 'DISABLED' ? 'DISABLED' : 'ENABLED',
          #:passive => bind['passive'],
        )
      end
    end

    instances
  end

  mk_resource_methods

  def property_to_rest_mapping
    {
      :state          => :monstate,
    }
  end

  def per_provider_munge(message)
    message[:name], message[:monitor_name] = message[:name].split('/')

    message
  end

  def destroy
    toname, fromname = resource.name.split('/').map { |n| URI.escape(n) }
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{toname}",{'args'=>"monitor_name:#{fromname}"})
    @property_hash.clear

    return result
  end
end

