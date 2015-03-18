require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_sslocspresponder).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def netscaler_api_type
    "sslocspresponder"
  end

  def self.instances
    instances = []
    sslocspresponders = Puppet::Provider::Netscaler.call('/config/sslocspresponder')
    return [] if sslocspresponders.nil?

    sslocspresponders.each do |sslocspresponder|
      instances << new(
        :ensure           => :present,
        :name             => sslocspresponder['name'],
        :url              => sslocspresponder['url'],
      )
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
    :name                         => :name,
    :url                          => :url,
    :cache                        => :cache,
    :cache_timeout                => :cachetimeout,
    :batching_depth               => :batchingdepth,
    :batching_delay               => :batchingdelay,
    :request_timeout              => :resptimeout,
    :certificate                  => :respondercert,
    :trust_responses              => :trustresponder,
    :produced_at_time_skew        => :producedattimeskew,
    :signing_certificate          => :signingcert,
    :nonce                        => :useonce,
    :client_certificate_insertion => :insertclientcert,
    }
  end

  def immutable_properties
    [
      :certificate_filename,
      :key_filename,
      :password,
      :fipskey,
      :certificate_format,
      :passplain,
      :bundle,
      :linkcert_keyname,
      :nodomain_check,
    ]
  end

  def per_provider_munge(message)
    message
  end
end
