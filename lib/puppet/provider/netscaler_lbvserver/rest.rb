require_relative '../../../puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_lbvserver).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def self.instances
    instances = []
    lb_vservers = Puppet::Provider::Netscaler.call('/config/lbvserver')
    return [] if lb_vservers.nil?

    lb_vservers.each do |lb_vserver|
      instances << new({
        :ensure                                 => :present,
        :name                                   => lb_vserver['name'],
        :service_type                           => lb_vserver['servicetype'],
        :ip_address                             => lb_vserver['ipv46'],
        :ip_pattern                             => lb_vserver['ippattern'],
        :ip_mask                                => lb_vserver['ipmask'],
        :port                                   => lb_vserver['port'],
        :range                                  => lb_vserver['range'],
        :persistence_type                       => lb_vserver['persistencetype'],
        :persistence_timeout                    => lb_vserver['timeout'],
        :persistence_backup                     => lb_vserver['persistencebackup'],
        :backup_persistence_timeout             => lb_vserver['backuppersistencetimeout'],
        :lb_method                              => lb_vserver['lbmethod'],
        :lb_method_hash_length                  => lb_vserver['hashlength'],
        :lb_method_netmask                      => lb_vserver['netmask'],
        :lb_method_ipv6_mask_length             => lb_vserver['v6netmasklen'],
        :cookie_name                            => lb_vserver['cookiename'],
        :rule                                   => lb_vserver['rule'],
        :listen_policy                          => lb_vserver['listenpolicy'],
        :listen_priority                        => lb_vserver['listenpriority'],
        :response_rule                          => lb_vserver['resrule'],
        :persistence_ipv4_mask                  => lb_vserver['persistmask'],
        :persistence_ipv6_mask_length           => lb_vserver['v6persistmasklen'],
        :priority_queuing                       => lb_vserver['pq'],
        :sure_connect                           => lb_vserver['sc'],
        :rtsp_natting                           => lb_vserver['rtspnat'],
        :redirection_mode                       => lb_vserver['m'],
        :tos_id                                 => lb_vserver['tosid'],
        :data_length                            => lb_vserver['datalength'],
        :data_offset                            => lb_vserver['dataoffset'],
        :sessionless                            => lb_vserver['sessionless'],
        :state                                  => lb_vserver['curstate'] == "OUT OF SERVICE" ? "DISABLED" : "ENABLED",
        :connection_failover                    => lb_vserver['connfailover'],
        :redirect_url                           => lb_vserver['redirurl'],
        :cacheable                              => lb_vserver['cacheable'],
        :client_timeout                         => lb_vserver['clttimeout'],
        :spillover_method                       => lb_vserver['somethod'],
        :spillover_persistence                  => lb_vserver['sopersistence'],
        :spillover_persistence_timeout          => lb_vserver['sopersistencetimeout'],
        :health_threshold                       => lb_vserver['healththreshold'],
        :spillover_threshold                    => lb_vserver['sothreshold'],
        :spillover_backup_action                => lb_vserver['sobackupaction'],
        :redirect_port_rewrite                  => lb_vserver['redirectportrewrite'],
        :down_state_flush                       => lb_vserver['downstateflush'],
        :backup_virtual_server                  => lb_vserver['backupvserver'],
        :disable_primary_on_down                => lb_vserver['disableprimaryondown'],
        :virtual_server_ip_port_insertion       => lb_vserver['insertvserveripport'],
        :vip_header_name                        => lb_vserver['vipheader'],
        :authentication_fqdn                    => lb_vserver['authenticationhost'],
        :authentication                         => lb_vserver['authentication'],
        :authentication_401                     => lb_vserver['authn401'],
        :authentication_virtual_server_name     => lb_vserver['authnvsname'],
        :push                                   => lb_vserver['push'],
        :push_virtual_server_name               => lb_vserver['pushvserver'],
        :push_label_expression                  => lb_vserver['pushlabel'],
        :push_multiple_clients                  => lb_vserver['pushmulticlients'],
        :tcp_profile_name                       => lb_vserver['tcpprofilename'],
        :http_profile_name                      => lb_vserver['httpprofilename'],
        :db_profile_name                        => lb_vserver['dbprofilename'],
        :comment                                => lb_vserver['comment'],
        :layer2_parameters                      => lb_vserver['l2conn'],
        :oracle_server_version                  => lb_vserver['oracleserverversion'],
        :mssql_server_version                   => lb_vserver['mssqlserverversion'],
        :mysql_protocol_version                 => lb_vserver['mysqlprotocolversion'],
        :mysql_server_version                   => lb_vserver['mysqlserverversion'],
        :mysql_character_set                    => lb_vserver['mysqlcharacterset'],
        :mysql_server_capabilities              => lb_vserver['mysqlservercapabilities'],
        :appflow_logging                        => lb_vserver['appflowlog'],
        :net_profile_name                       => lb_vserver['netprofile'],
        :icmp_virtual_server_response           => lb_vserver['icmpvsrresponse'],
        :rhi_state                              => lb_vserver['rhistate'],
        :new_service_request_rate               => lb_vserver['newservicerequest'],
        :new_service_request_unit               => lb_vserver['newservicerequestunit'],
        :new_service_request_increment_interval => lb_vserver['newservicerequestincrementinterval'],
        :min_autoscale_members                  => lb_vserver['minautoscalemembers'],
        :max_autoscale_members                  => lb_vserver['maxautoscalemembers'],
        :persist_avp_no                         => lb_vserver['persistavpno'],
        :skip_persistency                       => lb_vserver['skippersistency'],
        :traffic_domain                         => lb_vserver['td'],
        :authentication_profile_name            => lb_vserver['authnprofile'],
        :macmode_retain_vlan                    => lb_vserver['macmoderetainvlan'],
        :database_specific_lb                   => lb_vserver['dbslb'],
        :dns64                                  => lb_vserver['dns64'],
        :bypass_aaaa                            => lb_vserver['bypassaaaa'],
        :recursion_available                    => lb_vserver['recursionavailable'],
      })
    end

    instances
  end

  mk_resource_methods

  # Map irregular attribute names for conversion in the message.
  def property_to_rest_mapping
    {
      :ip_address                         => :ipv46,
      :response_rule                      => :resrule,
      :persistence_ipv4_mask              => :persistmask,
      :sure_connect                       => :sc,
      :rtsp_natting                       => :rtspnat,
      :redirect_url                       => :redirurl,
      :client_timeout                     => :clttimeout,
      :spillover_method                   => :somethod,
      :spillover_persistence              => :sopersistence,
      :spillover_persistence_timeout      => :sopersistencetimeout,
      :spillover_threshold                => :sothreshold,
      :spillover_backup_action            => :sobackupaction,
      :backup_virtual_server              => :backupvserver,
      :virtual_server_ip_port_insertion   => :insertvserveripport,
      :authentication_fqdn                => :authenticationhost,
      :authentication_401                 => :authn401,
      :authentication_virtual_server_name => :authnvsname,
      :push_virtual_server_name           => :pushvserver,
      :push_label_expression              => :pushlabel,
      :push_multiple_clients              => :pushmulticlients,
      :layer2_parameters                  => :l2conn,
      :appflow_logging                    => :appflowlog,
      :net_profile_name                   => :netprofile,
      :icmp_virtual_server_response       => :icmpvsrresponse,
      :new_service_request_rate           => :newservicerequest,
      :authentication_profile_name        => :authnprofile,
      :database_specific_lb               => :dbslb,
      :persistence_ipv6_mask_length       => :v6persistmasklen,
      :priority_queuing                   => :pq,
      :redirection_mode                   => :m,
      :connection_failover                => :connfailover,
      :traffic_domain                     => :td,
      :lb_method_hash_length              => :hashlength,
      :lb_method_netmask                  => :netmask,
      :lb_method_ipv6_mask_length         => :v6netmasklen,
      :vip_header_name                    => :vipheader,
      :persistence_timeout                => :timeout,
    }
  end

  def immutable_properties
    [
      :service_type,
      :port,
      :range,
      :traffic_domain,
    ]
  end

  def per_provider_munge(message)
    message
  end

  def netscaler_api_type
    "lbvserver"
  end
end
