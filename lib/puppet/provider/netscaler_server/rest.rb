require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_server).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def initialize(value={})
    super(value)
    if value.is_a? Hash
      @original_values = value.clone
    else
      @original_values = Hash.new
    end
    @create_elements = false
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

  def self.prefetch(resources)
    nodes = instances
    resources.keys.each do |name|
      if provider = nodes.find { |node| node.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @create_elements = true
    result = Puppet::Provider::Netscaler.post("/config/server", message(resource))
    @property_hash.clear

    return result
  end

  def destroy
    result = Puppet::Provider::Netscaler.delete("/config/server/#{resource}")
    @property_flush[:ensure] = :absent
  end

  def flush
    if @property_hash != {}
      result = Puppet::Provider::Netscaler.put("/config/server/#{resource[:name]}", message(@property_hash))
      # We have to update the state in a separate call.
      if @property_hash[:state] != @original_values[:state] and (result.status == 200 or result.status == 201)
        set_state(@property_hash[:state])
      end
    end
    return result
  end

  mk_resource_methods

  # I don't want to use `def state=` because that will be called before flush
  def set_state(value)
    case value
    when "ENABLED", "DISABLED"
      state = value.downcase.chop
      Puppet::Provider::Netscaler.post("/config/server/#{resource[:name]}?action=#{state}", {
        :server => {:name => resource[:name],}
      }.to_json)
    else
      raise ArgumentError, "Incorrect state: #{value}"
    end
  end

  def message(object)
    message = object.clone.to_hash

    # Map for conversion in the message.
    map = {
      :traffic_domain_id      => :td,
      :translation_ip_address => :translationip,
      :translation_mask       => :translationmask,
      :resolve_retry          => :domainresolveretry,
      :ipv6_domain            => :ipv6address,
      :comments               => :comment,
      :address                => :ipaddress
    }

    # Detect immutable properties
    if ! @create_elements
      [:traffic_domain_id, :ipv6_domain].each do |property|
        if message[property] != @original_values[property]
          raise ArgumentError, "Cannot update #{property} after creation"
        end
      end
      # Only domain names are immutable.
      if ! self.class.is_ip_address(message[:address])
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

    # Delete some properties if the resource already exists, since we can only
    # pass them on create. Otherwise we have to call #<property>=
    if ! @create_elements
      message.delete(:state)
      message.delete(:traffic_domain_id)
      message.delete(:ipv6_domain)
      message.delete(:domain)
    end

    # The netscaler must be explicitly told if the address is IPv4 or IPv6
    #if message[:address].match(Resolv::IPv6::Regex)
    #  message[:ipv6address]
    #end

    message = strip_nil_values(message)
    message = rename_keys(map, message)
    message = create_message(message)
    message = { :server => message }

    message = message.to_json
    message
  end
end
