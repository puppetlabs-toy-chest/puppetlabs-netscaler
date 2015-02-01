require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_lbmonitor).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def netscaler_api_type
    "lbmonitor"
  end

  def self.instances
    instances = []
    monitors = Puppet::Provider::Netscaler.call('/config/lbmonitor')
    return [] if monitors.nil?

    monitors.each do |monitor|
      instances << new(
        :ensure              => :present,
        ## Standard
        :name                                 => monitor['monitorname'],
        :type                                 => monitor['type'],
        :interval                             => monitor['interval'].to_i,
        :destination_ip                       => monitor['destip'],
        :response_timeout                     => monitor['resptimeout'],
        :destination_port                     => monitor['destport'],
        :down_time                            => monitor['downtime'],
        #:dynamic_timeout                      => monitor['dynamicresponsetimeout'],
        :deviation                            => monitor['deviation'],
        #:dynamic_interval                     => monitor['dynamicinterval'],
        :retries                              => monitor['retries'],
        :resp_timeout_threshold               => monitor['resptimoutthresh'],
        :snmp_alert_retries                   => monitor['alertretries'],
        :action                               => monitor['action'],
        :success_retries                      => monitor['successretries'],
        :failure_retries                      => monitor['failureretries'],
        :net_profile                          => monitor['netprofile'],
        :tos                                  => monitor['tos'],
        :tos_id                               => monitor['tosid'],
        :state                                => monitor['svrstate'] == "OUT OF SERVICE" ? "DISABLED" : "ENABLED",
        :reverse                              => monitor['reverse'],
        :transparent                          => monitor['transparent'],
        :lrtm                                 => monitor['lrtm'],
        :secure                               => monitor['secure'],
        :ip_tunnel                            => monitor['iptunnel'],
        ## Special
        :http_request                         => monitor['httprequest'],
        :response_codes                       => monitor['respcode'],
        :send_string                          => monitor['send'],
        :receive_string                       => monitor['recv'],
        :custom_header                        => monitor['customheaders'],
        :query                                => monitor['query'],
        :query_type                           => monitor['querytype'],
        :ip_address                           => monitor['ipaddress'],
        :script_name                          => monitor['scriptname'],
        :dispatcher_ip                        => monitor['dispatcherip'],
        :dispatcher_port                      => monitor['dispatcherport'],
        :file_name                            => monitor['filename'],
        :base_dn                              => monitor['basedn'],
        :bind_dn                              => monitor['binddn'],
        :filter                               => monitor['filter'],
        :attribute                            => monitor['attribute'],
        :valdiate_credentials                 => monitor['validatecred'],
        :user_name                            => monitor['username'],
        :password                             => monitor['password'],
        :group_name                           => monitor['group'],
        :radius_key                           => monitor['radkey'],
        :nas_id                               => monitor['radnasid'],
        :nas_ip                               => monitor['radnasip'],
        :account_status_type                  => monitor['radaccountype'],
        :framed_ip                            => monitor['radframedip'],
        :called_station_id                    => monitor['radapn'],
        :calling_station_id                   => monitor['radmsisd'],
        :account_session_id                   => monitor['radaccountsession'],
        :origin_host                          => monitor['originhost'],
        :vendor_id                            => monitor['vendorid'],
        :origin_realm                         => monitor['originrealm'],
        :firmware_revision                    => monitor['firmwarerevision'],
        :product_name                         => monitor['productname'],
        :inband_security_id                   => monitor['inbandsecurityid'],
        :host_ip                              => monitor['hostipaddress'],
        :authentication_application_ids       => monitor['authapplicationid'],
        :account_application_ids              => monitor['acctapplicationid'],
        :supported_vendor_ids                 => monitor['supportedvendorids'],
        :vendor_specific_vendor_id            => monitor['vendorspecificvendorid'],
        #:vendor_specific_auth_application_ids => monitor['???'],
        #:vendor_specific_acct_application_ids => monitor['???'],
        :script_arguments                     => monitor['scriptargs'],
        :sip_method                           => monitor['sipmethod'],
        :sip_uri                              => monitor['sipuri'],
        :sip_reg_uri                          => monitor['sipreguri'],
        :max_forwards                         => monitor['maxforwards'],
        :snmp_community                       => monitor['snmpcommunity'],
        :snmp_oid                             => monitor['snmpoid'],
        :snmp_threshold                       => monitor['snmpthreshold'],
        :database                             => monitor['database'],
        :sql_query                            => monitor['sqlquery'],
        :sid                                  => monitor['oraclesid'],
        :snmp_version                         => monitor['snmpversion'],
        :metric_table                         => monitor['metrictable'],
        :application_name                     => monitor['application'],
        :site_path                            => monitor['sitepath'],
        :rtsp_request                         => monitor['rtsprequest'],
        :secondary_password                   => monitor['secondarypassword'],
        :logon_point_name                     => monitor['logonpointname'],
        :logon_agent_service_version          => monitor['lasversion'],
        :domain                               => monitor['domain'],
        :expression                           => monitor['evalrule'],
        :protocol_version                     => monitor['mssqlprotocolversion'],
        :kcd_account                          => monitor['kcdaccount'],
        :store_db                             => monitor['storedb'],
        :store_name                           => monitor['storename'],
        :storefront_account_service           => monitor['storefrontacctservice'],
        :check_backend_services               => monitor['storefrontcheckbackendservices'],
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

  mk_resource_methods

  # Map irregular attribute names for conversion in the message.
  def property_to_rest_mapping
    {
      :name => :monitorname,
      :destination_ip => :destip,
      :response_timeout => :resptimeout,
      :destination_port => :destport,
      :dynamic_timeout => :dynamicresponsetimeout,
      :resp_timeout_threshold => :resptimeoutthresh,
      :snmp_alert_retries => :alertretries,
      :response_codes => :respcode,
      :send_string => :send,
      :receive_string => :recv,
      :custom_header => :customheaders,
      :validate_credentials => :validatecred,
      :group_name => :group,
      :radius_key => :radkey,
      :nas_id => :radnasid,
      :nas_ip => :radnasip,
      :account_status_type => :radaccounttype,
      :framed_ip => :radframedip,
      :called_station_id => :radapn,
      :calling_station_id => :radmsisd,
      :account_session_id => :radaccountsession,
      :host_ip => :hostipaddress,
      :authentication_application_ids => :authapplicationid,
      :account_application_ids => :acctapplicationid,
      :script_arguments => :scriptargs,
      :sid => :oraclesid,
      :application_name => :application,
      :logon_agent_service_version => :lasversion,
      :expression => :evalrule,
      :protocol_version => :mssqlprotocolversion,
      :storefront_account_service => :storefrontacctservice,
      :check_backend_services => :storefrontcheckbackendservices,
    }
  end

  def immutable_properties
    [
      :type,
    ]
  end

  def per_provider_munge(message)
    # The netscaler must be explicitly told if the address is IPv4 or IPv6
    #if message[:address].match(Resolv::IPv6::Regex)
    #  message[:ipv6address]
    #end
    if ! ["MSSQL-ECV","MYSQL-ECV"].include? message[:type]
      message.delete(:storedb)
    end
    if message[:type] != "STOREFRONT"
      message.delete(:storefront_account_service)
    end
    if message[:type] != "DIAMETER"
      message.delete(:vendor_id)
      message.delete(:firmware_revision)
    end
    message.delete(:max_forwards) if message[:max_forwards] == 0
    message.delete(:dynamic_interval)
    message.delete(:dynamic_timeout)
    message.delete(:action) if message[:action] == "Not applicable"

    message
  end
end
