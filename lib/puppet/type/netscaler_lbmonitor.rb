require 'puppet/parameter/netscaler_name'
require 'puppet/property/netscaler_truthy'
require 'puppet/property/netscaler_traffic_domain'

Puppet::Type.newtype(:netscaler_lbmonitor) do
  @doc = 'Manage service on the NetScaler appliance. If the service is domain based, before you create the service, create the server entry by using the add server command. Then, in this command, specify the Server parameter.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)
#monitorName
#Name for the monitor. Must begin with an ASCII alphanumeric or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#CLI Users: If the name includes one or more spaces, enclose the name in double or single quotation marks (for example, "my monitor" or 'my monitor').

  newproperty(:type) do
    desc "Type of monitor that you want to create.

Possible values: PING, TCP, HTTP, TCP-ECV, HTTP-ECV, UDP-ECV, DNS, FTP, LDNS-PING, LDNS-TCP, LDNS-DNS, RADIUS, USER, HTTP-INLINE, SIP-UDP, LOAD, FTP-EXTENDED, SMTP, SNMP, NNTP, MYSQL, MYSQL-ECV, MSSQL-ECV, ORACLE-ECV, LDAP, POP3, CITRIX-XML-SERVICE, CITRIX-WEB-INTERFACE, DNS-TCP, RTSP, ARP, CITRIX-AG, CITRIX-AAC-LOGINPAGE, CITRIX-AAC-LAS, CITRIX-XD-DDC, ND6, CITRIX-WI-EXTENDED, DIAMETER, RADIUS_ACCOUNTING, STOREFRONT, APPC, CITRIX-XNC-ECV, CITRIX-XDM"
    validate do |value|
      if ! [
        :'PING',
        :'TCP',
        :'HTTP',
        :'TCP-ECV',
        :'HTTP-ECV',
        :'UDP-ECV',
        :'DNS',
        :'FTP',
        :'LDNS-PING',
        :'LDNS-TCP',
        :'LDNS-DNS',
        :'RADIUS',
        :'USER',
        :'HTTP-INLINE',
        :'SIP-UDP',
        :'LOAD',
        :'FTP-EXTENDED',
        :'SMTP',
        :'SNMP',
        :'NNTP',
        :'MYSQL',
        :'MYSQL-ECV',
        :'MSSQL-ECV',
        :'ORACLE-ECV',
        :'LDAP',
        :'POP3',
        :'CITRIX-XML-SERVICE',
        :'CITRIX-WEB-INTERFACE',
        :'DNS-TCP',
        :'RTSP',
        :'ARP',
        :'CITRIX-AG',
        :'CITRIX-AAC-LOGINPAGE',
        :'CITRIX-AAC-LAS',
        :'CITRIX-XD-DDC',
        :'ND6',
        :'CITRIX-WI-EXTENDED',
        :'DIAMETER',
        :'RADIUS_ACCOUNTING',
        :'STOREFRONT',
        :'APPC',
        :'CITRIX-XNC-ECV',
        :'CITRIX-XDM',
      ].include? value.to_sym
        fail ArgumentError, "Valid options: PING, TCP, HTTP, TCP-ECV, HTTP-ECV, UDP-ECV, DNS, FTP, LDNS-PING, LDNS-TCP, LDNS-DNS, RADIUS, USER, HTTP-INLINE, SIP-UDP, LOAD, FTP-EXTENDED, SMTP, SNMP, NNTP, MYSQL, MYSQL-ECV, MSSQL-ECV, ORACLE-ECV, LDAP, POP3, CITRIX-XML-SERVICE, CITRIX-WEB-INTERFACE, DNS-TCP, RTSP, ARP, CITRIX-AG, CITRIX-AAC-LOGINPAGE, CITRIX-AAC-LAS, CITRIX-XD-DDC, ND6, CITRIX-WI-EXTENDED, DIAMETER, RADIUS_ACCOUNTING, STOREFRONT, APPC, CITRIX-XNC-ECV, CITRIX-XDM"
      end
    end
  end

  newproperty(:interval) do
    desc "Time interval between two successive probes. Must be greater than the value of Response Time-out.

Default value: 5

Minimum value: 1

Maximum value: 20940000"

    munge do |value|
      Integer(value)
    end
  end

  newproperty(:destination_ip) do
    desc "IP address of the service to which to send probes. If the parameter is set to 0, the IP address of the server to which the monitor is bound is considered the destination IP address."
  end

  newproperty(:response_timeout) do
    desc "Amount of time for which the appliance must wait before it marks a probe as FAILED. Must be less than the value specified for the Interval parameter.

Note: For UDP-ECV monitors for which a receive string is not configured, response timeout does not apply. For UDP-ECV monitors with no receive string, probe failure is indicated by an ICMP port unreachable error received from the service.

Default value: 2

Minimum value: 1

Maximum value: 20939000"

    munge do |value|
      Integer(value)
    end
  end

  newproperty(:destination_port) do
    desc "TCP or UDP port to which to send the probe. If the parameter is set to 0, the port number of the service to which the monitor is bound is considered the destination port. For a monitor of type USER, however, the destination port is the port number that is included in the HTTP request sent to the dispatcher. Does not apply to monitors of type PING."

    munge do |value|
      Integer(value)
    end
  end

  newproperty(:down_time) do
    desc "Time duration for which to wait before probing a service that has been marked as DOWN. Expressed in milliseconds, seconds, or minutes.

Default value: 30

Minimum value: 1

Maximum value: 20939000"

    munge do |value|
      Integer(value)
    end
  end

  #newproperty(:dynamic_timeout) do
  #  desc "Response timeout of the DRTM enabled monitor , calculated dynamically based on the history and current response time."
  #end

  newproperty(:deviation) do
    desc "Time value added to the learned average response time in dynamic response time monitoring (DRTM). When a deviation is specified, the appliance learns the average response time of bound services and adds the deviation to the average. The final value is then continually adjusted to accommodate response time variations over time. Specified in milliseconds, seconds, or minutes.

Maximum value: 20939000"
  end

  #newproperty(:dynamic_interval) do
  #  desc "Interval between monitoring probes for DRTM enabled monitor , calculated dynamically based monitor response time."
  #end

  newproperty(:retries) do
    desc "Maximum number of probes to send to establish the state of a service for which a monitoring probe failed.

Default value: 3

Minimum value: 1

Maximum value: 127"

    munge do |value|
      Integer(value)
    end
  end

  newproperty(:resp_timeout_threshold) do
    desc 'Response time threshold, specified as a percentage of the Response Time-out parameter. If the response to a monitor probe has not arrived when the threshold is reached, the appliance generates an SNMP trap called monRespTimeoutAboveThresh. After the response time returns to a value below the threshold, the appliance generates a monRespTimeoutBelowThresh SNMP trap. For the traps to be generated, the "MONITOR-RTO-THRESHOLD" alarm must also be enabled.

Maximum value: 100'
  end

  newproperty(:snmp_alert_retries) do
    desc "Number of consecutive probe failures after which the appliance generates an SNMP trap called monProbeFailed.

Maximum value: 32"

    munge do |value|
      Integer(value)
    end
  end

  newproperty(:action) do
    desc "Action to perform when the response to an inline monitor (a monitor of type HTTP-INLINE) indicates that the service is down. A service monitored by an inline monitor is considered DOWN if the response code is not one of the codes that have been specified for the Response Code parameter.

Available settings function as follows:

* NONE - Do not take any action. However, the show service command and the show lb monitor command indicate the total number of responses that were checked and the number of consecutive error responses received after the last successful probe.

* LOG - Log the event in NSLOG or SYSLOG.

* DOWN - Mark the service as being down, and then do not direct any traffic to the service until the configured down time has expired. Persistent connections to the service are terminated as soon as the service is marked as DOWN. Also, log the event in NSLOG or SYSLOG.

Possible values: NONE, LOG, DOWN

Default value: SM_DOWN"
  end

  newproperty(:success_retries) do
    desc "Number of consecutive successful probes required to transition a service's state from DOWN to UP.

Default value: 1

Minimum value: 1

Maximum value: 32"

    munge do |value|
      Integer(value)
    end
  end

  newproperty(:failure_retries) do
    desc "Number of retries that must fail, out of the number specified for the Retries parameter, for a service to be marked as DOWN. For example, if the Retries parameter is set to 10 and the Failure Retries parameter is set to 6, out of the ten probes sent, at least six probes must fail if the service is to be marked as DOWN. The default value of 0 means that all the retries must fail if the service is to be marked as DOWN.

Maximum value: 32"

    munge do |value|
      Integer(value)
    end
  end

  newproperty(:net_profile) do
    desc "Name of the network profile."
  end

  newproperty(:tos, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Probe the service by encoding the destination IP address in the IP TOS (6) bits.

Possible values: YES, NO","YES","NO")
  end

  newproperty(:tos_id) do
    desc "The TOS ID of the specified destination IP. Applicable only when the TOS parameter is set.

Minimum value: 1

Maximum value: 63"
  end

  newproperty(:state, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("State of the monitor. The DISABLED setting disables not only the monitor being configured, but all monitors of the same type, until the parameter is set to ENABLED. If the monitor is bound to a service, the state of the monitor is not taken into account when the state of the service is determined.", 'ENABLED', 'DISABLED')
  end

  newproperty(:reverse, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Mark a service as DOWN, instead of UP, when probe criteria are satisfied, and as UP instead of DOWN when probe criteria are not satisfied.

Possible values: YES, NO

Default value: NO","YES","NO")
  end

  newproperty(:transparent, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("The monitor is bound to a transparent device such as a firewall or router. The state of a transparent device depends on the responsiveness of the services behind it. If a transparent device is being monitored, a destination IP address must be specified. The probe is sent to the specified IP address by using the MAC address of the transparent device.

Possible values: YES, NO

Default value: NO","YES","NO")
  end

  newproperty(:lrtm, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Calculate the least response times for bound services. If this parameter is not enabled, the appliance does not learn the response times of the bound services. Also used for LRTM load balancing.

Possible values: ENABLED, DISABLED","ENABLED","DISABLED")
  end

  newproperty(:secure, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Use a secure SSL connection when monitoring a service. Applicable only to TCP based monitors. The secure option cannot be used with a CITRIX-AG monitor, because a CITRIX-AG monitor uses a secure connection by default.

Possible values: YES, NO

Default value: NO","YES","NO")
  end

  newproperty(:ip_tunnel, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Send the monitoring probe to the service through an IP tunnel. A destination IP address must be specified.

Possible values: YES, NO

Default value: NO","YES","NO")
  end

  newproperty(:http_request) do
    desc 'HTTP request to send to the server (for example, "HEAD /file.html").'
  end

  newproperty(:response_codes, :array_matching => :all) do
    desc "Response codes for which to mark the service as UP. For any other response code, the action performed depends on the monitor type. HTTP monitors and RADIUS monitors mark the service as DOWN, while HTTP-INLINE monitors perform the action indicated by the Action parameter."
  end

  newproperty(:send_string) do
    desc "String to send to the service. Applicable to TCP-ECV, HTTP-ECV, and UDP-ECV monitors."
  end

  newproperty(:receive_string) do
    desc "String expected from the server for the service to be marked as UP. Applicable to TCP-ECV, HTTP-ECV, and UDP-ECV monitors."
  end

  newproperty(:custom_header) do
    desc "Custom header string to include in the monitoring probes."
  end

  newproperty(:query) do
    desc "Domain name to resolve as part of monitoring the DNS service (for example, example.com)."
  end

  newproperty(:query_type) do
    desc "Type of DNS record for which to send monitoring queries. Set to Address for querying A records, AAAA for querying AAAA records, and Zone for querying the SOA record.

Possible values: Address, Zone, AAAA"
  end

  newproperty(:ip_address) do
    desc "Set of IP addresses expected in the monitoring response from the DNS server, if the record type is A or AAAA. Applicable to DNS monitors."
  end

  newproperty(:script_name) do
    desc "Path and name of the script to execute. The script must be available on the NetScaler appliance, in the /nsconfig/monitors/ directory."
  end

  newproperty(:dispatcher_ip) do
    desc "IP address of the dispatcher to which to send the probe."
  end

  newproperty(:dispatcher_port) do
    desc "Port number on which the dispatcher listens for the monitoring probe."

    munge do |value|
      Integer(value)
    end
  end

  newproperty(:file_name) do
    desc "Name of a file on the FTP server. The appliance monitors the FTP service by periodically checking the existence of the file on the server. Applicable to FTP-EXTENDED monitors."
  end

  newproperty(:base_dn) do
    desc "The base distinguished name of the LDAP service, from where the LDAP server can begin the search for the attributes in the monitoring query. Required for LDAP service monitoring."
  end

  newproperty(:bind_dn) do
    desc "The distinguished name with which an LDAP monitor can perform the Bind operation on the LDAP server. Optional. Applicable to LDAP monitors."
  end

  newproperty(:filter) do
    desc "Filter criteria for the LDAP query. Optional."
  end

  newproperty(:attribute) do
    desc "Attribute to evaluate when the LDAP server responds to the query. Success or failure of the monitoring probe depends on whether the attribute exists in the response. Optional."
  end

  newproperty(:validate_credentials, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Validate the credentials of the Xen Desktop DDC server user. Applicable to monitors of type CITRIX-XD-DDC.

Possible values: YES, NO

Default value: NO","YES","NO")
  end

  newproperty(:user_name) do
    desc "User name with which to probe the RADIUS, NNTP, FTP, FTP-EXTENDED, MYSQL, MSSQL, POP3, CITRIX-AG, CITRIX-XD-DDC, CITRIX-WI-EXTENDED, CITRIX-XNC or CITRIX-XDM server."
  end

  newproperty(:password) do
    desc "Password that is required for logging on to the RADIUS, NNTP, FTP, FTP-EXTENDED, MYSQL, MSSQL, POP3, CITRIX-AG, CITRIX-XD-DDC, CITRIX-WI-EXTENDED, CITRIX-XNC-ECV or CITRIX-XDM server. Used in conjunction with the user name specified for the User Name parameter."
  end

  newproperty(:group_name) do
    desc "Name of a newsgroup available on the NNTP service that is to be monitored. The appliance periodically generates an NNTP query for the name of the newsgroup and evaluates the response. If the newsgroup is found on the server, the service is marked as UP. If the newsgroup does not exist or if the search fails, the service is marked as DOWN. Applicable to NNTP monitors."
  end

  newproperty(:radius_key) do
    desc "Authentication key (shared secret text string) for RADIUS clients and servers to exchange. Applicable to monitors of type RADIUS and RADIUS_ACCOUNTING."
  end

  newproperty(:nas_id) do
    desc "NAS-Identifier to send in the Access-Request packet. Applicable to monitors of type RADIUS."
  end

  newproperty(:nas_ip) do
    desc "Network Access Server (NAS) IP address to use as the source IP address when monitoring a RADIUS server. Applicable to monitors of type RADIUS and RADIUS_ACCOUNTING."
  end

  newproperty(:account_type) do
    desc "Account Type to be used in Account Request Packet. Applicable to monitors of type RADIUS_ACCOUNTING.

Default value: 1

Maximum value: 15"
  end

  newproperty(:framed_ip) do
    desc "Source ip with which the packet will go out . Applicable to monitors of type RADIUS_ACCOUNTING."
  end

  newproperty(:called_station_id) do
    desc "Called Station Id to be used in Account Request Packet. Applicable to monitors of type RADIUS_ACCOUNTING."
  end

  newproperty(:calling_station_id) do
    desc "Calling Stations Id to be used in Account Request Packet. Applicable to monitors of type RADIUS_ACCOUNTING."
  end

  newproperty(:account_session_id) do
    desc "Account Session ID to be used in Account Request Packet. Applicable to monitors of type RADIUS_ACCOUNTING."
  end

  newproperty(:origin_host) do
    desc "Origin-Host value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers."
  end

  newproperty(:vendor_id) do
    desc "Vendor-Id value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers."
  end

  newproperty(:origin_realm) do
    desc "Origin-Realm value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers."
  end

  newproperty(:firmware_revision) do
    desc "Firmware-Revision value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers."
  end

  newproperty(:product_name) do
    desc "Product-Name value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers."
  end

  newproperty(:inband_security_id) do
    desc "Inband-Security-Id for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.

Possible values: NO_INBAND_SECURITY, TLS"
  end

  newproperty(:host_ip) do
    desc "Host-IP-Address value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers. If Host-IP-Address is not specified, the appliance inserts the mapped IP (MIP) address or subnet IP (SNIP) address from which the CER request (the monitoring probe) is sent."
  end

  newproperty(:authentication_application_ids) do
    desc "List of Auth-Application-Id attribute value pairs (AVPs) for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers. A maximum of eight of these AVPs are supported in a monitoring CER message.

Maximum value: 4294967295"
  end

  newproperty(:account_application_ids) do
    desc "List of Acct-Application-Id attribute value pairs (AVPs) for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers. A maximum of eight of these AVPs are supported in a monitoring message.

Maximum value: 4294967295"
  end

  newproperty(:supported_vendor_ids) do
    desc "List of Supported-Vendor-Id attribute value pairs (AVPs) for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers. A maximum eight of these AVPs are supported in a monitoring message.

Minimum value: 1

Maximum value: 4294967295"
  end

  newproperty(:vendor_specific_vendor_id) do
    desc "Vendor-Id to use in the Vendor-Specific-Application-Id grouped attribute-value pair (AVP) in the monitoring CER message. To specify Auth-Application-Id or Acct-Application-Id in Vendor-Specific-Application-Id, use vendorSpecificAuthApplicationIds or vendorSpecificAcctApplicationIds, respectively. Only one Vendor-Id is supported for all the Vendor-Specific-Application-Id AVPs in a CER monitoring message.

Minimum value: 1"
  end

  newproperty(:script_arguments) do
    desc "String of arguments for the script. The string is copied verbatim into the request."
  end

  newproperty(:sip_method) do
    desc "SIP method to use for the query. Applicable only to monitors of type SIP-UDP.

Possible values: OPTIONS, INVITE, REGISTER"
  end

  newproperty(:sip_uri) do
    desc "SIP URI string to send to the service (for example, sip:sip.test). Applicable only to monitors of type SIP-UDP."
  end

  newproperty(:sip_reg_uri) do
    desc "SIP user to be registered. Applicable only if the monitor is of type SIP-UDP and the SIP Method parameter is set to REGISTER."
  end

  newproperty(:max_forwards) do
    desc "Maximum number of hops that the SIP request used for monitoring can traverse to reach the server. Applicable only to monitors of type SIP-UDP.

Default value: 1

Maximum value: 255"
  end

  newproperty(:snmp_community) do
    desc "Community name for SNMP monitors."
  end

  newproperty(:snmp_oid) do
    desc "SNMP OID for SNMP monitors."
  end

  newproperty(:snmp_threshold) do
    desc "Threshold for SNMP monitors."
  end

  newproperty(:database) do
    desc "Name of the database to connect to during authentication."
  end

  newproperty(:sql_query) do
    desc "SQL query for a MYSQL-ECV or MSSQL-ECV monitor. Sent to the database server after the server authenticates the connection."
  end

  newproperty(:sid) do
    desc "Name of the service identifier that is used to connect to the Oracle database during authentication."
  end

  newproperty(:snmp_version) do
    desc "SNMP version to be used for SNMP monitors.

Possible values: V1, V2"
  end

  newproperty(:metric_table) do
    desc "Metric table to which to bind metrics."
  end

  newproperty(:application_name) do
    desc "Name of the application used to determine the state of the service. Applicable to monitors of type CITRIX-XML-SERVICE."
  end

  newproperty(:site_path) do
    desc "URL of the logon page. For monitors of type CITRIX-WEB-INTERFACE, to monitor a dynamic page under the site path, terminate the site path with a slash (/). Applicable to CITRIX-WEB-INTERFACE, CITRIX-WI-EXTENDED and CITRIX-XDM monitors."
  end

  newproperty(:rtsp_request) do
    desc 'RTSP request to send to the server (for example, "OPTIONS *").'
  end

  newproperty(:secondary_password) do
    desc "Secondary password that users might have to provide to log on to the Access Gateway server. Applicable to CITRIX-AG monitors."
  end

  newproperty(:logon_point_name) do
    desc "Name of the logon point that is configured for the Citrix Access Gateway Advanced Access Control software. Required if you want to monitor the associated login page or Logon Agent. Applicable to CITRIX-AAC-LAS and CITRIX-AAC-LOGINPAGE monitors."
  end

  newproperty(:logon_agent_service_version) do
    desc "Version number of the Citrix Advanced Access Control Logon Agent. Required by the CITRIX-AAC-LAS monitor."
  end

  newproperty(:domain) do
    desc "Domain in which the XenDesktop Desktop Delivery Controller (DDC) servers or Web Interface servers are present. Required by CITRIX-XD-DDC and CITRIX-WI-EXTENDED monitors for logging on to the DDC servers and Web Interface servers, respectively."
  end

  newproperty(:expression) do
    desc 'Default syntax expression that evaluates the database server\'s response to a MYSQL-ECV or MSSQL-ECV monitoring query. Must produce a Boolean result. The result determines the state of the server. If the expression returns TRUE, the probe succeeds.

For example, if you want the appliance to evaluate the error message to determine the state of the server, use the rule MYSQL.RES.ROW(10) .TEXT_ELEM(2).EQ("MySQL").'
  end

  newproperty(:protocol_version) do
    desc "Version of MSSQL server that is to be monitored.

Possible values: 70, 2000, 2000SP1, 2005, 2008, 2008R2, 2012

Default value: TDS_PROT_70"
  end

  newproperty(:kcd_account) do
    desc "KCD Account used by MSSQL monitor"
  end

  newproperty(:store_db) do
    desc "Store the database list populated with the responses to monitor probes. Used in database specific load balancing if MSSQL-ECV/MYSQL-ECV monitor is configured.

Possible values: ENABLED, DISABLED"
  end

  newproperty(:store_name) do
    desc "Store Name. For monitors of type STOREFRONT, STORENAME is an optional argument defining storefront service store name. Applicable to STOREFRONT monitors."
  end

  newproperty(:storefront_account_service) do
    desc "Enable/Disable probing for Account Service. Applicable only to Store Front monitors. For multi-tenancy configuration users my skip account service

Possible values: YES, NO

Default value: YES"
  end

  newproperty(:check_backend_services) do
    desc "This option will enable monitoring of services running on storefront server. Storefront services are monitored by probing to a Windows service that runs on the Storefront server and exposes details of which storefront services are running."
  end

  ###

  #XXX Where does this fit in? I didn't see any gui option for it
  #newproperty(:hostName) do
  #  desc "Hostname in the FQDN format (Example: porche.cars.org). Applicable to STOREFRONT monitors."
  #end

  #newproperty(:address) do
  #  options = '[ipv4|ipv6|domain name]'
  #  desc "The domain name, IPv4 address, or IPv6 address of the server. When creating an IP address-based server, you can specify the name of the server instead of its IP address, when creating a service.
  #  Valid options: #{options}"
  #  validate do |value|
  #    unless value.match(Resolv::IPv6::Regex) || value.match(Resolv::IPv4::Regex) || value
  #      fail ArgumentError, "#{name} must be: #{options}."
  #    end
  #  end
  #end

  #newproperty(:protocol) do
  #  desc 'Protocol in which data is exchanged with the service. Required.'
  #  validate do |value|
  #    if ! [
  #      :HTTP,
  #      :FTP,
  #      :TCP,
  #      :UDP,
  #      :SSL,
  #      :SSL_BRIDGE,
  #      :SSL_TCP,
  #      :DTLS,
  #      :NNTP,
  #      :RPCSVR,
  #      :DNS,
  #      :ADNS,
  #      :SNMP,
  #      :RTSP,
  #      :DHCPRA,
  #      :ANY,
  #      :SIP_UDP,
  #      :DNS_TCP,
  #      :ADNS_TCP,
  #      :MYSQL,
  #      :MSSQL,
  #      :ORACLE,
  #      :RADIUS,
  #      :RDP,
  #      :DIAMETER,
  #      :SSL_DIAMETER,
  #      :TFTP,
  #    ].include? value.to_sym
  #      fail ArgumentError, "Valid options: HTTP, FTP, TCP, UDP, SSL, SSL_BRIDGE, SSL_TCP, DTLS, NNTP, RPCSVR, DNS, ADNS, SNMP, RTSP, DHCPRA, ANY, SIP_UDP, DNS_TCP, ADNS_TCP, MYSQL, MSSQL, ORACLE, RADIUS, RDP, DIAMETER, SSL_DIAMETER, TFTP"
  #    end
  #  end
  #end

  #newproperty(:server_name) do
  #  desc "Name of the server that hosts the service. Required."
  #end

  #newproperty(:port) do
  #  desc "Port number of the service. Required."
  #  validate do |value|
  #    if ! (value =~ /^\d+$/ and Integer(value).between?(1,65535))
  #      fail ArgumentError, "port: #{value} is not a valid port."
  #    end
  #  end
  #  munge do |value|
  #    Integer(value)
  #  end
  #end

  ### Extra properties follow
  #newparam(:graceful_shutdown, :parent => Puppet::Property::NetscalerTruthy) do
  #  truthy_property("Indicates graceful shutdown of the server. System will wait for all outstanding connections to this server to be closed before disabling the server.", "YES", "NO")
  #end

  #newproperty(:traffic_domain_id, :parent => Puppet::Property::NetscalerTrafficDomain) do
  #end

  #newproperty(:hash_id) do
  #  desc "A numerical identifier that can be used by hash based load balancing methods. Must be unique for each service.

  #Minimum value: 1"

  #  validate do |value|
  #    if ! (value =~ /^\d+$/ and Integer(value).between?(1,4294967295))
  #      fail ArgumentError, "hash_id: #{value} must be an integer greater than 0."
  #    end
  #  end
  #  munge do |value|
  #    Integer(value)
  #  end
  #end

  #newproperty(:server_id) do
  #  desc "Unique identifier for the service. Used when the persistency type for the virtual server is set to Custom Server ID."
  #end

  #newproperty(:clear_text_port) do
  #  desc "Port to which clear text data must be sent after the appliance decrypts incoming SSL traffic. Applicable to transparent SSL services."
  #  validate do |value|
  #    if ! (value =~ /^\d+$/ and Integer(value).between?(1,65535))
  #      fail ArgumentError, "port: #{value} is not a valid port."
  #    end
  #  end
  #  munge do |value|
  #    Integer(value)
  #  end
  #end

  #newproperty(:cache_type) do
  #  desc "Cache type supported by the cache server."
  #  validate do |value|
  #    if ! [
  #      :SERVER,
  #      :TRANSPARENT,
  #      :REVERSE,
  #      :FORWARD,
  #    ].include? value.to_sym
  #      fail ArgumentError, "Valid options: SERVER, TRANSPARENT, REVERSE, FORWARD"
  #    end
  #  end
  #end

  #newproperty(:cacheable, :parent => Puppet::Property::NetscalerTruthy) do
  #  truthy_property("Use the transparent cache redirection virtual server to forward requests to the cache server. May not be specified if cache_type is 'TRANSPARENT', 'REVERSE', or 'FORWARD'", 'YES', 'NO')
  #end

  #newproperty(:health_monitoring, :parent => Puppet::Property::NetscalerTruthy) do
  #  truthy_property("Monitor the health of this service. Available settings function as follows:
  #YES - Send probes to check the health of the service.
  #NO - Do not send probes to check the health of the service. With the NO option, the appliance shows the service as UP at all times.", 'YES', 'NO')
  #end

  #newproperty(:appflow_logging, :parent => Puppet::Property::NetscalerTruthy) do
  #  truthy_property("Enable logging of AppFlow information.", 'ENABLED', 'DISABLED')
  #end

  #newproperty(:comments) do
  #  desc "Any information about the object."
  #end

  ### Properties that show up under edit in the gui
  #newproperty(:max_clients) do
  #  desc "Maximum number of simultaneous open connections to the service.

  #Max = 4294967294"
  #end

  #newproperty(:max_requests) do
  #  desc "Maximum number of requests that can be sent on a persistent connection to the service. 
  #Note: Connection requests beyond this value are rejected.

  #Max = 65535"
  #end

  #newproperty(:max_bandwidth) do
  #  desc "Maximum bandwidth, in Kbps, allocated to the service.

  #Max = 4294967287"
  #end

  #newproperty(:monitor_threshold) do
  #  desc "Minimum sum of weights of the monitors that are bound to this service. Used to determine whether to mark a service as UP or DOWN.

  #Max = 65535"
  #end

  #newproperty(:client_idle_timeout) do
  #  desc "Time, in seconds, after which to terminate an idle client connection.

  #Max = 31536000"
  #  validate do |value|
  #    if ! value =~ /^\d+$/
  #      fail ArgumentError, "client_idle_timeout: #{value} is not a valid integer."
  #    end
  #  end
  #  munge do |value|
  #    Integer(value)
  #  end
  #end

  #newproperty(:server_idle_timeout) do
  #  desc "Time, in seconds, after which to terminate an idle server connection.

  #Max = 31536000"
  #  validate do |value|
  #    if ! value =~ /^\d+$/
  #      fail ArgumentError, "server_idle_timeout: #{value} is not a valid integer."
  #    end
  #  end
  #  munge do |value|
  #    Integer(value)
  #  end
  #end

  #newproperty(:sure_connect, :parent => Puppet::Property::NetscalerTruthy) do
  #  truthy_property("State of SureConnect for the service.", 'ON', 'OFF')
  #end

  #newproperty(:surge_protection, :parent => Puppet::Property::NetscalerTruthy) do
  #  truthy_property("Enable surge protection for the service.", 'ON', 'OFF')
  #end

  #newproperty(:use_proxy_port, :parent => Puppet::Property::NetscalerTruthy) do
  #  truthy_property("Use the proxy port as the source port when initiating connections with the server. With the NO setting, the client-side connection port is used as the source port for the server-side connection.
  #Note: This parameter is available only when the Use Source IP (USIP) parameter is set to YES.", 'YES', 'NO')
  #end

  #newproperty(:down_state_flush, :parent => Puppet::Property::NetscalerTruthy) do
  #  truthy_property("Flush all active transactions associated with a service whose state transitions from UP to DOWN. Do not enable this option for applications that must complete their transactions.", 'ENABLED', 'DISABLED')
  #end

  #newproperty(:access_down, :parent => Puppet::Property::NetscalerTruthy) do
  #  truthy_property("Use Layer 2 mode to bridge the packets sent to this service if it is marked as DOWN. If the service is DOWN, and this parameter is disabled, the packets are dropped.", 'YES', 'NO')
  #end

  #newproperty(:use_source_ip, :parent => Puppet::Property::NetscalerTruthy) do
  #  truthy_property("Use the client's IP address as the source IP address when initiating a connection to the server. When creating a service, if you do not set this parameter, the service inherits the global Use Source IP setting (available in the enable ns mode and disable ns mode CLI commands, or in the System > Settings > Configure modes > Configure Modes dialog box). However, you can override this setting after you create the service.", 'YES', 'NO')
  #end

  #newproperty(:client_keepalive, :parent => Puppet::Property::NetscalerTruthy) do
  #  truthy_property("Enable client keep-alive for the service.", :'YES', 'NO')
  #end

  #newproperty(:tcp_buffering, :parent => Puppet::Property::NetscalerTruthy) do
  #  truthy_property("Enable TCP buffering for the service.", 'YES', 'NO')
  #end

  #newproperty(:client_ip, :parent => Puppet::Property::NetscalerTruthy) do
  #  truthy_property("Before forwarding a request to the service, insert an HTTP header with the client's IPv4 or IPv6 address as its value. Used if the server needs the client's IP address for security, accounting, or other purposes, and setting the Use Source IP parameter is not a viable option.", 'ENABLED', 'DISABLED')
  #end

  #newproperty(:client_ip_header) do
  #  desc "Name for the HTTP header whose value must be set to the IP address of the client. Used with the Client IP parameter. If you set the Client IP parameter, and you do not specify a name for the header, the appliance uses the header name specified for the global Client IP Header parameter (the cipHeader parameter in the set ns param CLI command or the Client IP Header parameter in the Configure HTTP Parameters dialog box at System > Settings > Change HTTP parameters). If the global Client IP Header parameter is not specified, the appliance inserts a header with the name \"client-ip.\""
  #end
  #newparam(:graceful_shutdown, :parent => Puppet::Property::NetscalerTruthy) do
  #  truthy_property("Indicates graceful shutdown of the server. System will wait for all outstanding connections to this server to be closed before disabling the server.", "YES", "NO")
  #end

  #newproperty(:translation_ip_address) do
  #  desc "IP address used to transform the server's DNS-resolved IP address."
  #  validate do |value|
  #    if ! value.match(Resolv::IPv4::Regex)
  #      raise ArgumentError, "translation_ip_address must be an IPv4 address."
  #    end
  #  end
  #end

  #newproperty(:translation_mask) do
  #  desc "The netmask of the translation ip"
  #  validate do |value|
  #    if ! value.match(Resolv::IPv4::Regex)
  #      raise ArgumentError, "translation_mask must be an IPv4 address."
  #    end
  #  end
  #end

  #newproperty(:resolve_retry) do
  #  desc "Time, in seconds, for which the NetScaler appliance must wait, after DNS resolution fails, before sending the next DNS query to resolve the domain name.

  #Default = 5
  #Min = 5
  #Max = 20939"
  #end

  #newproperty(:ipv6_domain, :parent => Puppet::Property::NetscalerTruthy) do
  #  truthy_property("Support IPv6 addressing mode. If you configure a server with the IPv6 addressing mode, you cannot use the server in the IPv4 addressing mode", "YES", "NO")
  #end

  ### This is handled with the "state" property
  ##newparam(:enable_after_creating, :parent => Puppet::Property::NetscalerTruthy) do
  ##  truthy_property("Initial state of the server.", :true, :false)
  ##end

  #validate do
  #  if self[:address] and (self[:address].match(Resolv::IPv6::Regex) || self[:address].match(Resolv::IPv4::Regex))
  #    if self[:translation_ip_address] or self[:translation_mask] or self[:resolve_retry] or self[:ipv6_domain]
  #      raise ArgumentError, "If address is an IP address, cannot configure any of translation_ip_address, translation_mask, ipv6_domain, or resolve_retry when address is an IP address."
  #    end
  #  end
  #end

  #validate do
  #  if self[:clear_text_port] and ! [:DTLS, :SSL, :SSL_TCP].include? self[:type].to_sym
  #    fail ArgumentError, "clear_text_port may only be set for DTLS, SSL, and SSL_TCP type."
  #  end
  #end
  #autorequire(:netscaler_server) do
  #  self[:server_name] if server = self[:server_name]
  #end
end
