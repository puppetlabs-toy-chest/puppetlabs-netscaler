require_relative '../../../puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_sslcertfile).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "sslcertfile"
  end

  def self.instances
    instances = []
    sslcertfiles = Puppet::Provider::Netscaler.call('/config/sslcertfile')
    #array can contain an empty hash, if there are no files uploaded
    return [] if sslcertfiles.nil? || sslcertfiles[0].empty?

    sslcertfiles.each do |sslcertfile|
      instances << new({
        :ensure => :present,
        :name   => sslcertfile['name'],
        :source => sslcertfile['src'],
      })
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :source => :src,
    }
  end

  def immutable_properties
    [
      :name,
      :source,
    ]
  end

  def create
    @create_elements = true
    result = Puppet::Provider::Netscaler.post("/config/#{netscaler_api_type}", message(resource), {"action" => "import"})
    @property_hash.clear

    return result
  end

  def destroy
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}", {'args'=>"name:#{resource.name}"})
    @property_hash.clear

    return result
  end

  def per_provider_munge(message)
    message
  end
end
