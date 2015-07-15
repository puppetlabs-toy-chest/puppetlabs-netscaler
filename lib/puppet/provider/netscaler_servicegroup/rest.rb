require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_servicegroup).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "servicegroup"
  end

  def self.instances
    instances = []
    services = Puppet::Provider::Netscaler.call('/config/servicegroup')
    return [] if services.nil?

    services.each do |service|
      if not service['autoscale'] or service['autoscale'] == 'DISABLED'
        autoscale_val = 'DISABLED'
      else
        autoscale_val = service['autoscale']
      end

      instances << new({
        :ensure              => :present,
        ## Create-only attributes
        :name                => service['servicegroupname'], #create
        :cache_type          => service['cachetype'],      #create
        :member_port         => service['memberport'],     #create
        :protocol            => service['servicetype'],    #create
        :state               => service['svrstate'] == "OUT OF SERVICE" ? "DISABLED" : "ENABLED",       #create
        :traffic_domain_id   => service['td'],             #create
        ## Create + Set attributes
        :appflow_logging     => service['appflowlog'],     #create, set, unset
        :cacheable           => service['cacheable'],      #create, set, unset
        :client_idle_timeout => service['clttimeout'],     #create, set, unset
        :client_ip           => service['cip'],            #create, set, unset
        :client_ip_header    => service['cipheader'],      #create, set, unset
        :client_keepalive    => service['cka'],            #create, set, unset
        :comments            => service['comment'],        #create, set, unset
        :down_state_flush    => service['downstateflush'], #create, set, unset
        :health_monitoring   => service['healthmonitor'],  #create, set, unset
        :maximum_bandwidth   => service['maxbandwidth'],   #create, set, unset
        :max_clients         => service['maxclient'],      #create, set, unset
        :max_requests        => service['maxreq'],         #create, set, unset
        :monitor_threshold   => service['monthreshold'],   #create, set, unset
        :server_idle_timeout => service['svrtimeout'],     #create, set, unset
        :sure_connect        => service['sc'],             #create, set, unset
        :surge_protection    => service['sp'],             #create, set, unset
        :tcp_buffering       => service['tcpb'],           #create, set, unset
        :use_proxy_port      => service['useproxyport'],   #create, set, unset
        :use_client_ip       => service['usip'],           #create, set, unset
        :autoscale_mode      => autoscale_val,
        :tcp_profile         => service['tcpprofilename'],
        :http_profile        => service['httpprofilename'],
        :net_profile         => service['netprofile'],
        ## Unknown create, set, & unset attributes
        #service['cmp']
        #service['pathmonitor']
        #service['pathmonitorindv']
        #service['rtspsessionidremap']
        #service['serverid'] (maybe unset?)
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
      :name                => :servicegroupname,
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
      :maximum_bandwidth   => :maxbandwidth,
      :monitor_threshold   => :monthreshold,
      :protocol            => :servicetype,
      :server_idle_timeout => :svrtimeout,
      :sure_connect        => :sc,
      :surge_protection    => :sp,
      :tcp_buffering       => :tcpb,
      :traffic_domain_id   => :td,
      :use_source_ip       => :usip,
      :tcp_profile         => :tcpprofilename,
      :http_profile        => :httpprofilename,
      :autoscale_mode      => :autoscale,
    }
  end

  def immutable_properties
    [
      :cache_type,
      :member_port,
      :protocol,
      :traffic_domain_id,
      :autoscale_mode
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

  def flush_state_args
    {
      :name_key => 'servicegroupname',
      :name_val => resource[:name],
    }
  end
end
