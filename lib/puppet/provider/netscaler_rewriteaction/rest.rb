require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_rewriteaction).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def netscaler_api_type
    "rewriteaction"
  end

  def self.instances
    instances = []
    rewriteactions = Puppet::Provider::Netscaler.call('/config/rewriteaction')
    return [] if rewriteactions.nil?

    rewriteactions.each do |rewriteaction|
    instances << new(
      :ensure              => :present,
      :name                => rewriteaction['name'],
      :type                => rewriteaction['type'],
      :target_expression   => rewriteaction['target'],
      :content_expression  => rewriteaction['stringbuilderexpr'],
      :pattern             => rewriteaction['pattern'],
      :search              => rewriteaction['search'],
      :bypass_safety_check => rewriteaction['bypasssafetycheck'],
      :refine_search       => rewriteaction['refinesearch'],
      :comments            => rewriteaction['comment'],
    )
end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :content_expression  => :stringbuilderexpr,
      :target_expression   => :target,
      :bypass_safety_check => :bypasssafetycheck,
      :refine_search       => :refinesearch,
      :comments            => :comment,
    }
  end

  def immutable_properties
    [
      :type,
    ]
  end

  def per_provider_munge(message)
    message
  end
end
