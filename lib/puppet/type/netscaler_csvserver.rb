require 'puppet/parameter/netscaler_name'
require 'puppet/property/netscaler_truthy'
require 'puppet/property/netscaler_traffic_domain'

Puppet::Type.newtype(:netscaler_csvserver) do
  @doc = 'Manage Content Switching VServer on the NetScaler appliance.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)

  newparam(:purge_bindings)

  newproperty(:traffic_domain) do
    desc "Integer value that uniquely identifies the traffic domain in which you want to configure the entity. If you do not specify an ID, the entity becomes part of the default traffic domain, which has an ID of 0.
Minimum value = 0
Maximum value = 4094"

    munge do |value|
      Integer(value)
    end

  end

  newproperty(:service_type) do
    desc "The service type of the virtual server. Valid options: HTTP, SSL, TCP, FTP, RTSP, SSL_TCP, UDP, DNS, SIP_UDP, ANY, RADIUS, RDP, MYSQL, MSSQL, DIAMETER, SSL_DIAMETER."

    validate do |value|
      if ! [:HTTP,:SSL,:TCP,:FTP,:RTSP,:SSL_TCP,:UDP,:DNS,:SIP_UDP,:ANY,:RADIUS,:RDP,:MYSQL,:MSSQL,:DIAMETER,:SSL_DIAMETER,].include? value.to_sym
        fail ArgumentError, "Valid options: HTTP, SSL, TCP, FTP, RTSP, SSL_TCP, UDP, DNS, SIP_UDP, ANY, RADIUS, RDP, MYSQL, MSSQL, DIAMETER, SSL_DIAMETER"
      end
    end

  end

  newproperty(:ip_address) do
    desc "The new IP address of the virtual server."

  end

  newproperty(:ip_pattern) do
    desc "The IP Pattern of the virtual server."

  end

  newproperty(:range) do
    desc "An IP address range.

  Minimum value: 1
  Maximum value: 254"

    munge do |value|
      Integer(value)
    end

  end

  newproperty(:port) do
    desc "A port number for the virtual server.
  Minimum value: 1"

    munge do |value|
      Integer(value)
    end

  end

  newproperty(:state, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("The initial state, enabled or disabled, of the virtual server.", 'ENABLED', 'DISABLED')

  end

  newproperty(:state_update, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("To enable the state update for a CSW vserver", 'ENABLED', 'DISABLED')

  end

  newproperty(:cacheable, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("The option to specify whether a virtual server used for content switching will route requests to the cache redirection virtual server before sending it to the configured servers.", 'YES', 'NO')

  end

  newproperty(:redirect_url) do
    desc "The redirect URL for content switching."

  end

  newproperty(:client_timeout) do
    desc "Client timeout in seconds.

  Maximum value: 31536000"

    munge do |value|
      Integer(value)
    end

  end

  newproperty(:precedence) do
    desc "The precedence on the content switching virtual server between rule-based and URL-based policies. The default precedence is set to RULE.
  If the precedence is configured as RULE, the incoming request is applied against the content switching policies created with the -rule argument. If none of the rules match, then the URL in the request is applied against the content switching policies created with the -url option.
  For example, this precedence can be used if certain client attributes (such as a specific type of browser) need to be served different content and all other clients can be served from the content distributed among the servers.
  If the precedence is configured as URL, the incoming request URL is applied against the content switching policies created with the -url option. If none of the policies match, then the request is applied against the content switching policies created with the -rule option.
  Also, this precedence can be used if some content (such as images) is the same for all clients, but other content (such as text) is different for different clients. In this case, the images will be served to all clients, but the text will be served to specific clients based on specific attributes, such as Accept-Language. Valid options: RULE, URL."

    validate do |value|
      if ! [:RULE,:URL,].include? value.to_sym
        fail ArgumentError, "Valid options: RULE, URL"
      end
    end

  end

  newproperty(:case_sensitive, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("The URL lookup case option on the content switching vserver.
  If case sensitivity of a content switching virtual server is set to 'ON', the URLs /a/1.html and /A/1.HTML are treated differently and may have different targets (set by content switching policies).
  If case sensitivity is set to 'OFF', the URLs /a/1.html and /A/1.HTML are treated the same, and will be switched to the same target.", 'ON', 'OFF')

  end

  newproperty(:spillover_method) do
    desc "The spillover factor. When traffic on the main virtual server reaches this threshold, additional traffic is sent to the backupvserver. Valid options: CONNECTION, DYNAMICCONNECTION, BANDWIDTH, HEALTH, NONE."

    validate do |value|
      if ! [:CONNECTION,:DYNAMICCONNECTION,:BANDWIDTH,:HEALTH,:NONE,].include? value.to_sym
        fail ArgumentError, "Valid options: CONNECTION, DYNAMICCONNECTION, BANDWIDTH, HEALTH, NONE"
      end
    end

  end

  newproperty(:spillover_persistence, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("The state of the spillover persistence.", 'ENABLED', 'DISABLED')

  end

  newproperty(:spillover_threshold) do
    desc "If the spillover method is set to CONNECTION or DYNAMICCONNECTION, this value is treated as the maximum number of connections a virtual server will handle before spillover takes place. If the spillover method is set to BANDWIDTH, this value is treated as the amount of incoming and outgoing traffic (in Kbps) a vserver will handle before spillover takes place.
  Minimum value: 1
  Maximum value: 4294967287"

    munge do |value|
      Integer(value)
    end

  end

  newproperty(:spillover_backup_action) do
    desc "Action to be performed if spillover is to take effect, but no backup chain to spillover is usable or exists.
Valid options: DROP, ACCEPT, REDIRECT"

    validate do |value|
      if ! [:DROP,:ACCEPT,:REDIRECT,].include? value.to_sym
          fail ArgumentError, "Valid options: DROP, ACCEPT, REDIRECT"
      end
    end

  end

  newproperty(:redirect_port_rewrite, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("SSL redirect port rewrite.", 'ENABLED', 'DISABLED')

  end

  newproperty(:down_state_flush, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Perform delayed clean up of connections on this vserver.", 'ENABLED', 'DISABLED')

  end

  newproperty(:backup_virtual_server) do
    desc "The backup virtual server for content switching."

  end

  newproperty(:disable_primary_on_down, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("When this argument is enabled, traffic will continue reaching backup vservers even after primary comes UP from DOWN state.", 'ENABLED', 'DISABLED')

  end

  newproperty(:virtual_server_ip_port_insertion) do
    desc "The virtual IP and port header insertion option for the vserver.
    VIPADDR - Header contains the vserver's IP address and port number without any translation.
    OFF - The virtual IP and port header insertion option is disabled.
    V6TOV4MAPPING - Header contains the mapped IPv4 address that corresponds to the IPv6 address of the vserver and the port number. An IPv6 address can be mapped to a user-specified IPv4 address using the set ns ip6 command."

    validate do |value|
      if ! [:OFF,:VIPADDR,:V6TOV4MAPPING,].include? value.to_sym
        fail ArgumentError, "Valid options: OFF, VIPADDR, V6TOV4MAPPING"
      end
    end

  end

  newproperty(:vip_header_name) do
    desc "Name of virtual server IP and port header, for use with the VServer IP Port Insertion parameter.
Minimum length = 1"

  end

  newproperty(:rtsp_natting, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Use this parameter to enable natting for RTSP data connection.", 'ON', 'OFF')

  end

  newproperty(:authentication_fqdn) do
    desc "FQDN of authentication vserver"

  end

  newproperty(:authentication, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("This option toggles on or off the application of authentication of incoming users to the vserver.", 'ON', 'OFF')

  end

  newproperty(:listen_policy) do
    desc "Use this parameter to specify the listen policy for CS Vserver.
  The string can be either an existing expression name (configured using add policy expression command) or else it can be an in-line expression with a maximum of 1499 characters."

  end

  newproperty(:listen_priority) do
    desc "Use this parameter to specify the priority for listen policy of CS Vserver.

  Maximum value: 100"

    munge do |value|
      Integer(value)
    end

  end

  newproperty(:authentication_401, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("This option toggles on or off the HTTP 401 response based authentication.", 'ON', 'OFF')

  end

  newproperty(:authentication_virtual_server_name) do
    desc "Name of authentication vserver"

  end

  newproperty(:push, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Process traffic on bound Push vserver.", 'ENABLED', 'DISABLED')

  end

  newproperty(:push_virtual_server_name) do
    desc "The lb vserver of type PUSH/SSL_PUSH to which server pushes the updates received on the client facing non-push lb vserver."

  end

  newproperty(:push_label_expression) do
    desc "Use this parameter to specify the expression to extract the label in response from server.
  The string can be either a named expression (configured using add policy expression command) or else it can be an in-line expression with a maximum of 63 characters."

  end

  newproperty(:push_multiple_clients, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Specify if multiple web 2.0 connections from the same client can connect to this vserver and expect updates.", 'YES', 'NO')

  end

  newproperty(:tcp_profile_name) do
    desc "The name of the TCP profile."

  end

  newproperty(:http_profile_name) do
    desc "Name of the HTTP profile."

  end

  newproperty(:db_profile_name) do
    desc "Name of the DB profile."

  end

  newproperty(:oracle_server_version) do
    desc "Oracle server version. Valid options: 10G, 11G."

    validate do |value|
      if ! [:'10G',:'11G',].include? value.to_sym
        fail ArgumentError, "Valid options: 10G, 11G"
      end
    end

  end

  newproperty(:comment) do
    desc "Comments associated with this virtual server."

  end

  newproperty(:mssql_server_version) do
    desc "The version of the MSSQL server. Valid options: 70, 2000, 2000SP1, 2005, 2008, 2008R2."

    validate do |value|
      if ! [:'70',:'2000',:'2000SP1',:'2005',:'2008',:'2008R2',].include? value.to_sym
        fail ArgumentError, "Valid options: 70, 2000, 2000SP1, 2005, 2008, 2008R2"
      end
    end

  end

  newproperty(:layer2_parameters, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Use L2 Parameters to identify a connection", 'ON', 'OFF')

  end

  newproperty(:mysql_protocol_version) do
    desc "The protocol version returned by the mysql vserver."

    munge do |value|
      Integer(value)
    end

  end

  newproperty(:mysql_server_version) do
    desc "The server version string returned by the mysql vserver."

  end

  newproperty(:mysql_character_set) do
    desc "The character set returned by the mysql vserver."

    munge do |value|
      Integer(value)
    end

  end

  newproperty(:mysql_server_capabilities) do
    desc "The server capabilities returned by the mysql vserver."

    munge do |value|
      Integer(value)
    end

  end

  newproperty(:appflow_logging, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Enable logging appflow flow information", 'ENABLED', 'DISABLED')

  end

  newproperty(:net_profile_name) do
    desc "The name of the network profile."

  end

  newproperty(:icmp_virtual_server_response) do
    desc "Can be active or passive. Valid options: PASSIVE, ACTIVE."

    validate do |value|
      if ! [:PASSIVE,:ACTIVE,].include? value.to_sym
        fail ArgumentError, "Valid options: PASSIVE, ACTIVE"
      end
    end

  end

  newproperty(:ip_mask) do
    desc "The IP Mask of the virtual server IP Pattern"

  end

  newproperty(:spillover_persistence_timeout) do
    desc "The spillover persistency entry timeout.

  Minimum value: 2
  Maximum value: 1440"

    munge do |value|
      Integer(value)
    end

  end

  newproperty(:rhi_state) do
    desc "A host route is injected according to the setting on the virtual servers * If set to PASSIVE on all the virtual servers that share the IP address, the appliance always injects the hostroute. * If set to ACTIVE on all the virtual servers that share the IP address, the appliance injects even if one virtual server is UP. * If set to ACTIVE on some virtual servers and PASSIVE on the others, the appliance, injects even if one virtual server set to ACTIVE is UP. Valid options: PASSIVE, ACTIVE"

    validate do |value|
      if ! [:PASSIVE,:ACTIVE,].include? value.to_sym
        fail ArgumentError, "Valid options: PASSIVE, ACTIVE"
      end
    end

  end

  newproperty(:authentication_profile_name) do
    desc "Name of the authentication profile to be used when authentication is turned on."

  end

  newproperty(:default_lbvserver) do
    desc "The virtual server name to which content will be switched."

  end

  def generate
    return [] unless value(:purge_bindings) == true

    system_resources = []

    # gather a list of all relevant bindings present on the system
    system_resources += Puppet::Type.type(:netscaler_csvserver_rewritepolicy_bind).instances
    system_resources += Puppet::Type.type(:netscaler_csvserver_responderpolicy_bind).instances

    # Reject all resources that are in the catalog
    system_resources.delete_if { |res| catalog.resource_refs.include? res.ref }

    # Keep only our own bindings
    system_resources.delete_if { |res| (res[:name].split('/')[0] != value(:name)) }

    # We mark all remaining resources for deletion
    system_resources.each {|res| res[:ensure] = :absent}

    system_resources
  end

  autorequire(:netscaler_lbvserver) do
    self[:default_lbvserver]
  end

end

 
