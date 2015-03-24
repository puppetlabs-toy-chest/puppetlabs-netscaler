require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_feature).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def netscaler_api_type
    "nsfeature"
  end

  def self.instances
    instances = []

    features = Puppet::Provider::Netscaler.call('/config/nsfeature')

    features.delete('feature')
  
    features.each do |feature|
      # map rest name to english name (ie wl to Web Logging)
      name = Puppet::Type::Netscaler_feature.rest_name_map[feature[0]]

      if (name != nil)  
        instances << new(
          :name => name,
          :ensure => feature[1] ? :present : :absent,
        )
      end
    end

    instances
  end

  def create 
    save
  end
  
  def flush
    # do nothing
  end

  def destroy
    save
  end
  
  def save 
    action = case resource[:ensure]
      when :present then 'enable'
      when :absent then 'disable'
    end
    
    # map english name to rest name, ie Web Logging to wl
    rest_name = Puppet::Type::Netscaler_feature.rest_name_map.rassoc(resource[:name])[0]
    
    result = Puppet::Provider::Netscaler.post("/config/nsfeature", { :nsfeature => { :feature => rest_name } }.to_json, {"action" => action})    
  end
  
  
  
end
