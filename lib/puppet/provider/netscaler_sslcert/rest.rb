require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_sslcert).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def netscaler_api_type
    "sslcert"
  end

  def self.instances
    instances = []
    sslcerts = Puppet::Provider::Netscaler.call('/config/sslcertkey')
    return [] if sslcerts.nil?

    sslcerts.each do |sslcert|
      instances << new(
        :ensure                 => :present,
        :name                   => sslcert['cert'],
        :certfile               => sslcert['cert'],
#        :reqfile                => sslcert['reqfile'],
#        :certtype               => sslcert['certtype'],
        :keyfile                => sslcert['key'],
#        :keyform                => sslcert['keyform'],
#        :pempassphrase          => sslcert['pempassphrase'],
#        :days                   => sslcert['days'],
#        :certform               => sslcert['certform'],
#        :cacert                 => sslcert['cacert'],
#        :cacertform             => sslcert['cacertform'],
#        :cakey                  => sslcert['cakey'],
#        :cakeyform              => sslcert['cakeyform'],
#        :cakeyserial            => sslcert['cakeyserial'],
      )
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
    }
  end

  def immutable_properties
    [
    ]
  end

  def create
    @create_elements = true
    result = Puppet::Provider::Netscaler.post("/config/#{netscaler_api_type}", message(resource), {"action" => "create"})
    @property_hash.clear

    return result
  end

  def per_provider_munge(message)
    message.delete(:name)
    message
  end
end
