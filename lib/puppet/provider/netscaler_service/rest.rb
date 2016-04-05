require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_service).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "service"
  end

  def self.instances
    instances = []
    services = Puppet::Provider::Netscaler.call('/config/service')
    return [] if services.nil?

    services.each do |service|
      instances << new({
        :ensure              => :present,
        ## Create-only attributes
        :name                => service['name'],           #create
        :cache_type          => service['cachetype'],      #create
        :clear_text_port     => service['cleartextport'],  #create
        :port                => service['port'],           #create
        :protocol            => service['servicetype'],    #create
        :server_name         => service['servername'],     #create
        :state               => service['svrstate'] == "OUT OF SERVICE" ? "DISABLED" : "ENABLED",       #create
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
        :use_compression     => service['cmp'],            #create, set, unset
        ## Unknown create, set, & unset attributes
        #service['pathmonitor']
        #service['pathmonitorindv']
        #service['rtspsessionidremap']
        #service['serverid'] (maybe unset?)
        #service['tcpprofilename']
        #service['httpprofilename']
        :net_profile_name    => service['netprofile'],
        #service['processlocal']
        ## Unknown set attributes
        #service['weight']
        ## Unknown unset attributes
        #service['riseapbrstatsmsgcode'] # Is this even valid?
      })
    end

    instances
  end

  mk_resource_methods

  # Map irregular attribute names for conversion in the message.
  def property_to_rest_mapping
    {
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
      :net_profile_name    => :netprofile,
      :protocol            => :servicetype,
      :server_id           => :customserverid,
      :server_idle_timeout => :svrtimeout,
      :sure_connect        => :sc,
      :surge_protection    => :sp,
      :tcp_buffering       => :tcpb,
      :traffic_domain_id   => :td,
      :use_source_ip       => :usip,
      :use_compression     => :cmp,
    }
  end

  def immutable_properties
    [
      :cache_type,
      :clear_text_port,
      :port,
      :protocol,
      :server_name,
      :traffic_domain_id,
    ]
  end

  def per_provider_munge(message)
    # The netscaler must be explicitly told if the address is IPv4 or IPv6
    #if message[:address].match(Resolv::IPv6::Regex)
    #  message[:ipv6address]
    #end

    # SERVER is the default and not accepted by the rest API
    message.delete(:cache_type) if message[:cache_type] == 'SERVER'

    message
  end
end
