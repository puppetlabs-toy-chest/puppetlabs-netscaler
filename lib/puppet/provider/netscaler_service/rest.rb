require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_service).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def self.instances
    instances = []
    services = Puppet::Provider::Netscaler.call('/config/service')
    return [] if services.nil?

    services.each do |service|
      instances << new(
        :ensure              => :present,
        ## Create-only attributes
        :name                => service['name'],           #create
        :cache_type          => service['cachetype'],      #create
        :clear_text_port     => service['cleartextport'],  #create
        :port                => service['port'],           #create
        :protocol            => service['servicetype'],    #create
        :server_name         => service['servername'],     #create
        :state               => service['state'],          #create
        :traffic_domain_id   => service['td'],             #create
        ## Create + Set attributes
        :access_down         => service['accessdown'],     #create, set, unset
        :appflow_logging     => service['appflowlog'],     #create, set, unset
        :cacheable           => service['cacheable'],      #create, set, unset
        :client_idle_timeout => service['clttimeout'],     #create, set, unset
        :client_ip           => service['cip'],            #create, set, unset
        :client_ip_header    => service['cipheader'],      #create, set, unset
        :client_keepalive    => service['cka'],            #create, set, unset
        :comments            => service['comment'],        #create, set, unset
        :down_state_flush    => service['downstateflush'], #create, set, unset
        :hash_id             => service['hashid'],         #create, set, unset
        :health_monitoring   => service['healthmonitor'],  #create, set, unset
        :max_bandwidth       => service['maxbandwidth'],   #create, set, unset
        :max_clients         => service['maxclient'],      #create, set, unset
        :max_requests        => service['maxreq'],         #create, set, unset
        :monitor_threshold   => service['monthreshold'],   #create, set, unset
        :server_id           => service['customserverid'], #create, set, unset
        :server_idle_timeout => service['svrtimeout'],     #create, set, unset
        :sure_connect        => service['sc'],             #create, set, unset
        :surge_protection    => service['sp'],             #create, set, unset
        :tcp_buffering       => service['tcpb'],           #create, set, unset
        :use_proxy_port      => service['useproxyport'],   #create, set, unset
        :use_source_ip       => service['usip'],           #create, set, unset
        ## Unknown create, set, & unset attributes
        #service['cmp']
        #service['pathmonitor']
        #service['pathmonitorindv']
        #service['rtspsessionidremap']
        #service['serverid'] (maybe unset?)
        #service['tcpprofilename']
        #service['httpprofilename']
        #service['netprofile']
        #service['processlocal']
        ## Unknown set attributes
        #service['weight']
        ## Unknown unset attributes
        #service['riseapbrstatsmsgcode'] # Is this even valid?
      )
    end

    instances
  end

  def create
    @create_elements = true
    result = Puppet::Provider::Netscaler.post("/config/service", message(resource))
    @property_hash.clear

    return result
  end

  def destroy
    result = Puppet::Provider::Netscaler.delete("/config/service/#{resource}")
    @property_flush[:ensure] = :absent
  end

  def flush
    if @property_hash != {}
      #handle_unbinds('service', @original_values['binds'] - message['binds']) if ! @create_elements
      result = Puppet::Provider::Netscaler.put("/config/service/#{resource[:name]}", message(@property_hash))
      #handle_binds('service', message['binds'] - @original_values['binds']) if ! @create_elements
      # We have to update the state in a separate call.
      if @property_hash[:state] != @original_values[:state] and (result.status == 200 or result.status == 201)
        set_state(@property_hash[:state])
      end
    end
    return result
  end

  mk_resource_methods

  def message(object)
    message = object.clone.to_hash

    # Map irregular attribute names for conversion in the message.
    map = {
      :appflow_logging     => :appflowlog,
      :client_idle_timeout => :clttimeout,
      :client_ip           => :cip,
      :client_ip_header    => :cipheader,
      :client_keepalive    => :cka,
      :comments            => :comment,
      :graceful_shutdown   => :graceful,
      :health_monitoring   => :healthmonitor,
      :max_clients         => :maxclient,
      :max_requests        => :maxreq,
      :monitor_threshold   => :monthreshold,
      :protocol            => :servicetype,
      :server_id           => :customserverid,
      :server_idle_timeout => :svrtimeout,
      :sure_connect        => :sc,
      :surge_protection    => :sp,
      :tcp_buffering       => :tcpb,
      :traffic_domain_id   => :td,
      :use_source_ip       => :usip,
    }

    non_create_elements = [
      :cache_type,
      :clear_text_port,
      :port,
      :protocol,
      :server_name,
      :traffic_domain_id,
    ]

    # Detect immutable properties
    if ! @create_elements
      non_create_elements.each do |property|
        if message[property] != @original_values[property]
          raise ArgumentError, "Cannot update #{property} after creation"
        end
      end
    end

    # Delete some properties if the resource already exists, since we can only
    # pass them on create. Otherwise we have to call #<property>=
    if ! @create_elements
      message = message.reject do |key, value|
        non_create_elements.include? key
      end
      # And also...
      message.delete(:state)
    end

    # The netscaler must be explicitly told if the address is IPv4 or IPv6
    #if message[:address].match(Resolv::IPv6::Regex)
    #  message[:ipv6address]
    #end

    # SERVER is the default and not accepted by the rest API
    message.delete(:cache_type) if message[:cache_type] == 'SERVER'

    message = strip_nil_values(message)
    message = rename_keys(map, message)
    message = remove_underscores(message)
    message = create_message(message)
    message = { :service => message }

    message = message.to_json
    message
  end
end
