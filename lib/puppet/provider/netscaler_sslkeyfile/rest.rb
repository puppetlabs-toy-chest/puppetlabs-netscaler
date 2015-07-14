require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_sslkeyfile).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "sslkeyfile"
  end

  def self.instances
    instances = []
    sslkeyfiles = Puppet::Provider::Netscaler.call('/config/sslkeyfile')
    #array can contain an empty hash, if there are no files uploaded
    return [] if sslkeyfiles.nil? || sslkeyfiles[0].empty?

    sslkeyfiles.each do |sslkeyfile|
      instances << new(
        :ensure => :present,
        :name   => sslkeyfile['name'],
        :source => sslkeyfile['src'],
      )
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
