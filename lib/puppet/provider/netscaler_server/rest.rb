require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_server).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "server"
  end

  def self.instances
    instances = []
    servers = Puppet::Provider::Netscaler.call('/config/server')
    return [] if servers.nil?

    servers.each do |server|
      instances << new(
        :ensure                 => :present,
        :name                   => server['name'],
        :address                => server['ipaddress'] || server['domain'],
        :traffic_domain_id      => server['td'],
        :translation_ip_address => server['ipaddress'] ? nil : server['translationip'],
        :translation_mask       => server['ipaddress'] ? nil : server['translationmask'],
        :resolve_retry          => server['ipaddress'] ? nil : server['domainresolveretry'],
        :ipv6_domain            => server['ipaddress'] ? nil : server['ipv6address'],
        :state                  => server['state'],
        :comments               => server['comment'],
      )
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :traffic_domain_id      => :td,
      :translation_ip_address => :translationip,
      :resolve_retry          => :domainresolveretry,
      :ipv6_domain            => :ipv6address,
      :comments               => :comment,
      :address                => :ipaddress
    }
  end

  def immutable_properties
    [
      :ipv6_domain,
      :traffic_domain_id,
    ]
  end
  def per_provider_munge(message)
    if ! @create_elements
      # Only ip addresses are mutable.
      if self.class.is_ip_address(message[:address])
        #If :domain is in the @property_hash, that means the resource is
        #a domain resource. If the user passed in an IP as :address, bad
        #things will happen, but we'll go ahead and try the rest call
        #anyway...
        message.delete(:domain)
      else
        if message[:address] != @original_values[:address]
          raise ArgumentError, "Cannot change a domain address after creation."
        end
      end
    end

    # Detect if the address is an IP or a domain name
    if ! self.class.is_ip_address(message[:address])
      message[:domain] = message[:address]
      message.delete(:address)
    end

    # The netscaler must be explicitly told if the address is IPv4 or IPv6
    #XXX is this true?
    #if message[:address].match(Resolv::IPv6::Regex)
    #  message[:ipv6address]
    #end

    message
  end
end
