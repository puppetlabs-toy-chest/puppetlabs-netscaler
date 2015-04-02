require 'puppet/provider/netscaler'
require 'base64'
require 'json'

Puppet::Type.type(:netscaler_group).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def netscaler_api_type
    "systemgroup"
  end

  def self.instances
    instances = []
    #look for groups at a certain location
    groups = Puppet::Provider::Netscaler.call("/config/systemgroup")
    return [] if groups.nil?

    groups.each do |group|
        instances << new(
          :ensure                  => :present,
          :name                    => group['groupname'],
          :cli_prompt              => group['promptstring'],
          :idle_time_out           => group['timeout'].to_s,
        )
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :name                    => :groupname,
      :cli_prompt              => :promptstring,
      :idle_time_out           => :timeout,
    }
  end

  def immutable_properties
    [
    ]
  end

  def destroy
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{resource.name}")
    @property_hash.clear
    return result
  end

  def per_provider_munge(message)
    message
  end
end
