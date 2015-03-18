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
      instances << new(
        :name => feature[0],
        :ensure => feature[1] ? :present : :absent,
      )
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
    
    result = Puppet::Provider::Netscaler.post("/config/nsfeature", { :nsfeature => { :feature => resource[:name] } }.to_json, {"action" => action})    
  end
end
