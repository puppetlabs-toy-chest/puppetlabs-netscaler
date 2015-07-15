require 'puppet/provider/netscaler'
require 'base64'
require 'json'

Puppet::Type.type(:netscaler_user).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "systemuser"
  end

  def self.instances
    instances = []
    #look for users at a certain location
    users = Puppet::Provider::Netscaler.call("/config/systemuser")
    return [] if users.nil?

    users.each do |user|
        instances << new({
          :ensure                  => :present,
          :name                    => user['username'],
          :password                => user['password'],
          :external_authentication => user['externalauth'],
          :cli_prompt              => user['promptstring'],
          :idle_time_out           => user['timeout'].to_s,
          :logging_privilege       => user['logging'],
        })
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :name                    => :username,
      :external_authentication => :externalauth,
      :cli_prompt              => :promptstring,
      :idle_time_out           => :timeout,
      :logging_privilege       => :logging,
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
