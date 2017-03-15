require_relative '../../../puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_csvserver).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def self.instances
    instances = []
    cs_vservers = Puppet::Provider::Netscaler.call('/config/csvserver')
    return [] if cs_vservers.nil?

    cs_vservers.each do |cs_vserver|
      lbvserver_binds = Puppet::Provider::Netscaler.call("/config/csvserver_lbvserver_binding/#{cs_vserver['name']}") || []
      if !lbvserver_binds.empty?
        default_lbvserver = lbvserver_binds[0]['lbvserver']
      end

      instances << new({
        :ensure                             => :present,
        :name                               => cs_vserver['name'],
        :traffic_domain                     => cs_vserver['td'],
        :service_type                       => cs_vserver['servicetype'],
        :ip_address                         => cs_vserver['ipv46'],
        :ip_pattern                         => cs_vserver['ippattern'],
        :ip_mask                            => cs_vserver['ipmask'],
        :range                              => cs_vserver['range'],
        :port                               => cs_vserver['port'],
        :state                              => cs_vserver['curstate'] == "OUT OF SERVICE" ? "DISABLED" : "ENABLED",
        :state_update                       => cs_vserver['stateupdate'],
        :cacheable                          => cs_vserver['cacheable'],
        :redirect_url                       => cs_vserver['redirecturl'],
        :client_timeout                     => cs_vserver['clttimeout'],
        :precedence                         => cs_vserver['precedence'],
        :case_sensitive                     => cs_vserver['casesensitive'],
        :spillover_method                   => cs_vserver['somethod'],
        :spillover_persistence              => cs_vserver['sopersistence'],
        :spillover_persistence_timeout      => cs_vserver['sopersistencetimeout'],
        :spillover_threshold                => cs_vserver['sothreshold'],
        :spillover_backup_action            => cs_vserver['sobackupaction'],
        :redirect_port_rewrite              => cs_vserver['redirectportrewrite'],
        :down_state_flush                   => cs_vserver['downstateflush'],
        :backup_virtual_server              => cs_vserver['backupvserver'],
        :disable_primary_on_down            => cs_vserver['disableprimaryondown'],
        :virtual_server_ip_port_insertion   => cs_vserver['insertvserveripport'],
        :vip_header_name                    => cs_vserver['vipheader'],
        :rtsp_natting                       => cs_vserver['rtspnat'],
        :authentication_fqdn                => cs_vserver['authenticationhost'],
        :authentication                     => cs_vserver['authentication'],
        :listen_policy                      => cs_vserver['listenpolicy'],
        :listen_priority                    => cs_vserver['listenpriority'],
        :authentication_401                 => cs_vserver['authn401'],
        :authentication_virtual_server_name => cs_vserver['authnvsname'],
        :push                               => cs_vserver['push'],
        :push_virtual_server_name           => cs_vserver['pushvserver'],
        :push_label_expression              => cs_vserver['pushlabel'],
        :push_multiple_clients              => cs_vserver['pushmulticlients'],
        :tcp_profile_name                   => cs_vserver['tcpprofilename'],
        :http_profile_name                  => cs_vserver['httpprofilename'],
        :db_profile_name                    => cs_vserver['dbprofilename'],
        :oracle_server_version              => cs_vserver['oracleserverversion'],
        :comment                            => cs_vserver['comment'],
        :mssql_server_version               => cs_vserver['mssqlserverversion'],
        :layer2_parameters                  => cs_vserver['l2conn'],
        :mysql_protocol_version             => cs_vserver['mysqlprotocolversion'],
        :mysql_server_version               => cs_vserver['mysqlserverversion'],
        :mysql_character_set                => cs_vserver['mysqlcharacterset'],
        :mysql_server_capabilities          => cs_vserver['mysqlservercapabilities'],
        :appflow_logging                    => cs_vserver['appflowlog'],
        :net_profile_name                   => cs_vserver['netprofile'],
        :icmp_virtual_server_response       => cs_vserver['icmpvsrresponse'],
        :rhi_state                          => cs_vserver['rhistate'],
        :authentication_profile_name        => cs_vserver['authnprofile'],
        :default_lbvserver                  => default_lbvserver ? default_lbvserver : nil,
      })
    end

    instances
  end

  mk_resource_methods

  # Map irregular attribute names for conversion in the message.
  def property_to_rest_mapping
    {
      :ip_address                         => :ipv46,
      :client_timeout                     => :clttimeout,
      :spillover_method                   => :somethod,
      :spillover_persistence              => :sopersistence,
      :spillover_threshold                => :sothreshold,
      :backup_virtual_server              => :backupvserver,
      :virtual_server_ip_port_insertion   => :insertvserveripport,
      :rtsp_natting                       => :rtspnat,
      :authentication_fqdn                => :authenticationhost,
      :authentication_virtual_server_name => :authnvsname,
      :push_virtual_server_name           => :pushvserver,
      :push_label_expression              => :pushlabel,
      :push_multiple_clients              => :pushmulticlients,
      :layer2_parameters                  => :l2conn,
      :appflow_logging                    => :appflowlog,
      :net_profile_name                   => :netprofile,
      :icmp_virtual_server_response       => :icmpvsrresponse,
      :spillover_persistence_timeout      => :sopersistencetimeout,
      :spillover_backup_action            => :sobackupaction,
      :vip_header_name                    => :vipheader,
      :traffic_domain                     => :td,
      :authentication_401                 => :authn401,
      :authentication_profile_name        => :authnprofile,
    }
  end

  def immutable_properties
    [
     :service_type,
     :range,
     :port,
     :traffic_domain,
    ]
  end

  def per_provider_munge(message)
    message.delete(:purge_bindings)
    message.delete(:default_lbvserver)
    message
  end

  def netscaler_api_type
    "csvserver"
  end

  def create
    @create_elements = true
    result = Puppet::Provider::Netscaler.post("/config/#{netscaler_api_type}", message(resource))

    # Handle csvserver->lbvserver binding
    if (resource[:default_lbvserver])
      binding_property_hash = { :name => resource[:name], :lbvserver => resource[:default_lbvserver] }
      Puppet::Provider::Netscaler.post("/config/csvserver_lbvserver_binding", message_custom(binding_property_hash, "csvserver_lbvserver_binding"))
    end

    @property_hash.clear

    return result
  end

  def flush
    if @property_hash and ! @property_hash.empty?

      # We need to remove values from property hash that aren't specified in the Puppet resource
      @property_hash = @property_hash.reject { |k, v| !(resource[k]) }

      result = Puppet::Provider::Netscaler.put("/config/#{netscaler_api_type}/#{resource[:name]}", message(@property_hash))

      # Additional REST calls
      if  result.status == 200 or result.status == 201

        # We have to update the state in a separate call.
        if @property_hash[:state] and (@property_hash[:state] != @original_values[:state])
          set_state(@property_hash[:state], flush_state_args[:name_key], flush_state_args[:name_val])
        end

        # If csvservr->lbserver binding has not been created yet
        if (!@original_values[:default_lbvserver] and resource[:default_lbvserver])
          binding_property_hash = { :name => resource[:name], :lbvserver => resource[:default_lbvserver] }
          Puppet::Provider::Netscaler.post("/config/csvserver_lbvserver_binding", message_custom(binding_property_hash, "csvserver_lbvserver_binding"))

        # # If csvservr->lbserver binding needs deleted
        # elsif (!resource[:default_lbvserver] and @original_values[:default_lbvserver])
        #   #TODO?

        # If csvservr->lbserver binding needs updated
        elsif (resource[:default_lbvserver] and resource[:default_lbvserver] != @original_values[:default_lbvserver])
          Puppet::Provider::Netscaler.delete("/config/csvserver_lbvserver_binding/#{resource[:name]}",{'args'=>"lbvserver:#{@original_values[:default_lbvserver]}"})
          binding_property_hash = { :name => resource[:name], :lbvserver => resource[:default_lbvserver] }
          Puppet::Provider::Netscaler.post("/config/csvserver_lbvserver_binding", message_custom(binding_property_hash, "csvserver_lbvserver_binding"))
        end
      end
    end

    return result
  end

  def message_custom(object, api_type)
    message = object.clone.to_hash
    message = { api_type => message }
    message = message.to_json
    message
  end
end
