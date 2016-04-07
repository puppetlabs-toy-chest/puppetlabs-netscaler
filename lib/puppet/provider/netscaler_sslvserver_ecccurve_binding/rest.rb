require 'puppet/provider/netscaler'

require 'json'

Puppet::Type.type(:netscaler_sslvserver_ecccurve_binding).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  # Provider for sslvserver_ecccurve_binding: Binds an SSL certificate-key pair or an SSL policy to an ecc curve.
  def netscaler_api_type
    "sslvserver_ecccurve_binding"
  end

  def self.instances
    instances = []
    sslvservers = Puppet::Provider::Netscaler.call('/config/sslvserver')
    return [] if sslvservers.nil?

    sslvservers.each do |sslvserver|
      binds = Puppet::Provider::Netscaler.call("/config/sslvserver_ecccurve_binding/#{sslvserver['vservername']}") || []

      binds.each do |bind|
        instances << new({
          :ensure => :present,
          :name   => "#{bind['vservername']}/#{bind['ecccurvename']}",

        })
      end
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
    :name          => :vservername,
    }
  end

  def immutable_properties
    [
      :crlcheck,
      :ca,
      :snicert,
      :skipcaname,
      :ocspcheck,
    ]
  end

  def destroy
    vservername, ecccurvename = resource.name.split('/')
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{vservername}", {'args'=>"ecccurvename:#{ecccurvename}"})
    @property_hash.clear
    return result
  end

  def per_provider_munge(message)
    message[:vservername], message[:ecccurvename] = message[:name].split('/')
    message.delete(:name)

    message
  end
end
