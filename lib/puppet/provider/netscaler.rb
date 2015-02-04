require 'puppet/util/network_device/netscaler'
require 'puppet/util/network_device/transport/netscaler'
require 'json'

class Puppet::Provider::Netscaler < Puppet::Provider
  def initialize(value={})
    super(value)
    if value.is_a? Hash
      @original_values = value.clone
    else
      @original_values = Hash.new
    end
    @create_elements = false
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
    result = Puppet::Provider::Netscaler.post("/config/#{netscaler_api_type}", message(resource))
    @property_hash.clear

    return result
  end

  def destroy
    Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{resource[:name]}")
    @property_hash[:ensure] = :absent
  end

  def flush
    if @property_hash != {}
      #handle_unbinds('service', @original_values['binds'] - message['binds']) if ! @create_elements

      # We need to remove values from property hash that aren't specified in the Puppet resource
      @property_hash = @property_hash.reject { |k, v| !(resource[k]) }

      result = Puppet::Provider::Netscaler.put("/config/#{netscaler_api_type}/#{resource[:name]}", message(@property_hash))
      #handle_binds('service', message['binds'] - @original_values['binds']) if ! @create_elements
      # We have to update the state in a separate call.
      if @property_hash[:state] != @original_values[:state] and (result.status == 200 or result.status == 201)
        set_state(@property_hash[:state])
      end
    end
    return result
  end

  def self.device(url)
    Puppet::Util::NetworkDevice::Netscaler::Device.new(url)
  end

  def self.transport
    if Puppet::Util::NetworkDevice.current
      #we are in `puppet device`
      Puppet::Util::NetworkDevice.current.transport
    else
      #we are in `puppet resource`
      Puppet::Util::NetworkDevice::Transport::Netscaler.new(Facter.value(:url))
    end
  end

  def self.connection
    transport.connection
  end

  def self.call(url)
    transport.call(url)
  end

  def self.post(url, message)
    transport.post(url, message)
  end

  def self.put(url, message)
    transport.put(url, message)
  end

  def self.delete(url,args=nil)
    transport.delete(url,args)
  end

  def basename
    File.basename(resource[:name])
  end

  # A helper to get the kind of netscaler thing we're managing; ie
  # service, lbvserver, lbmonitor, etc.
  def netscaler_api_type
    # Each provider must implement this
    raise RuntimeError, "Unimplemented method #netscaler_api_type"
  end

  # I don't want to use `def state=` because that will be called before flush
  def set_state(value)
    case value
    when "ENABLED", "DISABLED"
      state = value.downcase.chop
      Puppet::Provider::Netscaler.post("/config/#{netscaler_api_type}/#{resource[:name]}?action=#{state}", {
        netscaler_api_type => {:name => resource[:name],}
      }.to_json)
    else
      err "Incorrect state: #{value}"
    end
  end

  def property_to_rest_mapping
    # Each provider must implement this
    raise RuntimeError, "Unimplemented method #property_to_rest_mapping"
  end

  def immutable_properties
    # Each provider must implement this
    raise RuntimeError, "Unimplemented method #immutable_properties"
  end

  def per_provider_munge(message)
    # Each provider must implement this
    raise RuntimeError, "Unimplemented method #per_provider_munge"
  end

  def global_provider_munge(message)
    if ! @create_elements
      immutable_properties.each do |property|
        if message[property] and message[property] != @original_values[property]
          err "Cannot update #{property} after creation"
        end
      end
      # Delete some properties if the resource already exists, since we can only
      # pass them on create. Otherwise we have to call #<property>=
      message = message.reject do |key, value|
        immutable_properties.include? key
      end
      # And also...
      message.delete(:state)
    end

    message = strip_nil_values(message)
    message = rename_keys(property_to_rest_mapping, message)
    message = remove_underscores(message)
    message = create_message(message)
    message = { netscaler_api_type => message }

    message
  end

  def message(object)
    message = object.clone.to_hash

    message = per_provider_munge(message)
    message = global_provider_munge(message)

    message = message.to_json
    message
  end

  #def self.find_availability(string)
  #  transport.find_availability(string)
  #end

  #def self.find_monitors(string)
  #  transport.find_monitors(string)
  #end

  #def self.integer?(str)
  #  !!Integer(str)
  #rescue ArgumentError, TypeError
  #  false
  #end

  # This allows us to simply rename keys from the puppet representation
  # to the Netscaler representation.
  def rename_keys(keys_to_rename, rename_hash)
    keys_to_rename.each do |k, v|
      next unless rename_hash[k]
      value = rename_hash[k]
      rename_hash.delete(k)
      rename_hash[v] = value
    end
    return rename_hash
  end

  def create_message(hash)
    # Create the message by stripping :present.
    new_hash            = hash.reject { |k, _| [:ensure, :provider, Puppet::Type.metaparams].flatten.include?(k) }

    return new_hash
  end

  def string_to_integer(hash)
    # Apply transformations
    hash.each do |k, v|
      hash[k] = Integer(v) if self.class.integer?(v)
    end
  end

  #def monitor_conversion(hash)
  #  message = hash
  #  # If monitor is an array then we need to rebuild the message.
  #  if hash[:availability]
  #    if hash[:availability] == "all"
  #      message[:monitor] = Array(hash[:monitor]).join(' and ')
  #    elsif hash[:availability] > 0
  #      message[:monitor] = "min #{hash[:availability]} of #{Array(hash[:monitor]).join(' ')}"
  #    end
  #    hash.delete(:availability)
  #  else
  #    message[:monitor] = Array(hash[:monitor]).join(' and ')
  #  end
  #  message.merge(hash)
  #end

  #def destination_conversion(message)
  #  if message[:'alias-address'] and message[:'alias-service-port']
  #    message[:destination] = "#{message[:'alias-address']}:#{message[:'alias-service-port']}"
  #  elsif message[:'alias-address']
  #    message[:destination] = message[:'alias-address']
  #  end
  #  message.delete(:'alias-address')
  #  message.delete(:'alias-service-port')

  #  return message
  #end

  ## We need to convert our puppet array into a \n seperated string.
  #def headers_conversion(message)
  #  if message[:headers]
  #    message[:headers] = message[:headers].join("\n")
  #  end

  #  return message
  #end

  ## We need to convert our puppet array into a space seperated string.
  #def filters_conversion(message)
  #  if message[:filter]
  #    message[:filter] = message[:filter].join(' ')
  #  end
  #  if message[:filterNeg]
  #    message[:filterNeg] = message[:filterNeg].join(' ')
  #  end

  #  return message
  #end

  def remove_underscores(hash)
    # We want to remove all _'s in the key names of the hash we create
    # from the object we've passed into message.
    hash.inject({}) do |memo, (k,v)|
      key = k.to_s.gsub(/_/, '').to_sym
      memo[key] = v
      memo
    end
  end

  #def strip_elements(hash, elements_to_strip)
  #  message = hash.reject { |k, _| elements_to_strip.include?(k) }

  #  return message
  #end

  # For some reason the object we pass in has undefined parameters in the
  # object with nil values.  Not at all helpful for us.
  def strip_nil_values(hash)
    hash.reject { |k, v| v.nil? }
  end

  def self.is_ip_address(value)
    !! (value and (value.match(Resolv::IPv6::Regex) or value.match(Resolv::IPv4::Regex)))
  end

  ## Find the type of a given profile in the profile cache, or if it is not found
  ## try reloading the cache and looking again.
  #def self.find_profile_type(profile)
  #  profiles = @@profile_cache ||= sort_profiles
  #  if profiles[profile]
  #    profiles[profile]
  #  else
  #    @@profile_cache = sort_profiles
  #    @@profile_cache[profile]
  #  end
  #end

  ## Find all profiles on the Netscaler and associate them as
  ## <profile name> => <profile type>
  ## (profile names are unique for all profile types)
  #def self.sort_profiles
  #  profile_types = Puppet::Provider::Netscaler.call("/mgmt/tm/ltm/profile").collect do |hash|
  #    hash["reference"]["link"].match(%r{([^/]+)\?})[1]
  #  end
  #  profile_types.inject({}) do |memo,profile_type|
  #    profile_array = Puppet::Provider::Netscaler.call("/mgmt/tm/ltm/profile/#{profile_type}") || []
  #    profile_hash = profile_array.inject({}) do |m,profile|
  #      m.merge!(profile["fullPath"] => profile_type)
  #    end
  #    memo.merge! profile_hash
  #  end
  #end
end
