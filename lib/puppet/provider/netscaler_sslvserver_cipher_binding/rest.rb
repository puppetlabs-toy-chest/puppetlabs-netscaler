require 'puppet/provider/netscaler'

require 'json'

Puppet::Type.type(:netscaler_sslvserver_cipher_binding).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  # Provider for sslvserver_cipher_binding: Binds an SSL certificate-key pair or an SSL policy to an cipher.
  def netscaler_api_type
    "sslvserver_cipher_binding"
  end

  def self.instances
    instances = []
    sslvservers = Puppet::Provider::Netscaler.call('/config/sslvserver')
    return [] if sslvservers.nil?

    sslvservers.each do |sslvserver|
      binds = Puppet::Provider::Netscaler.call("/config/sslvserver_cipher_binding/#{sslvserver['vservername']}") || []

      binds.each do |bind|
        instances << new({
          :ensure => :present,
          :name   => "#{bind['vservername']}/#{bind['ciphername']}",

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
    vservername, ciphername = resource.name.split('/')
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{vservername}", {'args'=>"ciphername:#{ciphername}"})
    @property_hash.clear
    return result
  end

  def per_provider_munge(message)
    message[:vservername], message[:ciphername] = message[:name].split('/')
    message.delete(:name)

    message
  end
end
