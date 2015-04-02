require 'puppet/provider/netscaler'

require 'json'

Puppet::Type.type(:netscaler_group_user_bind).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def netscaler_api_type
    "systemgroup_systemuser_binding"
  end

  def self.instances
    instances = []
    #look for files at a certain location
    groups = Puppet::Provider::Netscaler.call('/config/systemgroup')
    return [] if groups.nil?

    groups.each do |group|
      group_user_bindings = Puppet::Provider::Netscaler.call("/config/systemgroup_systemuser_binding/#{group['groupname']}") || []
      group_user_bindings.each do |group_user_binding|
        instances << new(
          :ensure => :present,
          :name   => "#{group_user_binding['groupname']}/#{group_user_binding['username']}",
        )
      end
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

  def destroy
    groupname, username = resource.name.split('/')
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{groupname}", {'args'=>"username:#{username}"})
    @property_hash.clear
    return result
  end

  def per_provider_munge(message)
    message[:groupname], message[:username] = message[:name].split('/')
    message.delete(:name)

    message
  end
end
