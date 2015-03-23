require 'puppet/provider/netscaler'
require 'base64'
require 'json'

Puppet::Type.type(:netscaler_file).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def netscaler_api_type
    "systemfile"
  end

  def self.instances
    instances = []
    #look for files at a certain location
    files = Puppet::Provider::Netscaler.call('/config/systemfile',{'args'=>"filelocation:%2Fnsconfig%2F"})
    return [] if files.nil?

    files.each do |file|
      binds = Puppet::Provider::Netscaler.call("/config/systemfile", {'args'=>"filelocation:%2Fnsconfig%2F,filename:#{file['filename']}"}) || [] 
      binds.each do |bind|
        instances << new(
          :ensure       => :present,
          :name         => bind['filename'],
          :content      => bind['filecontent'],
          :fileencoding => bind['fileencoding'],
        )
      end
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :name       => :filename,
      :content    => :filecontent,
    }
  end

  def immutable_properties
    [
      :fileencoding,
    ]
  end

  def destroy
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{resource.name}", {'args'=>"filelocation:%2Fnsconfig%2F"})
    @property_hash.clear
    return result
  end

  def per_provider_munge(message)
    message[:filelocation] = '/nsconfig/'
    message[:content] =  Base64.strict_encode64(message[:content])
    message
  end
end
