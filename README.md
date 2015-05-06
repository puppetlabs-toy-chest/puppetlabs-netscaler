#netscaler

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with netscaler](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with netscaler](#beginning-with-netscaler)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

The netscaler module enables Puppet configuration of Citrix NetScaler devices through types and REST-based providers.

##Module Description

This module uses REST to manage various aspects of NetScaler load balancers, and acts
as a foundation for building higher level abstractions within Puppet.

The module allows you to manage NetScaler nodes and pool configuration through Puppet.

##Setup

###Beginning with netscaler

Before you can use the netscaler module, you must create a proxy system able to run `puppet device`.  In order to do so, you will have a Puppet master and a Puppet agent as usual, and the agent will be the "proxy system" for the `puppet device` subcommand.

**NOTE: `puppet device` was designed to interact with admininistrative interfaces in order to run commands that implement types and providers. `puppet device` allows you to write a resource to talk to the device and translates the module into network calls.**

**TODO^^^ Run that by Hunter.**

This means you must create a device.conf file in the Puppet conf directory (either /etc/puppet or /etc/puppetlabs/puppet) on the Puppet agent. Within your device.conf, you must have:

**TODO:Check this**
~~~
[certname]
type netscaler
url https://<USERNAME>:<PASSWORD>@<netscaler1.example.com>/
~~~

In the above example, <USERNAME> and <PASSWORD> refer to Puppet's login for the device.

Additionally, you must install the faraday gem on the proxy host (Puppet agent). You can do this by declaring the **TODO:What class?** class on that host. If you do not install the faraday gem, the module will not work.

##Usage

###Set up two load-balanced web servers.

####Before you begin

This example is built around the following infrastructure: A server running a Puppet master is connected to the NetScaler device. The NetScaler device contains a management VLAN, a client VLAN which will contain the virtual server, and a server VLAN which will connect to the two web servers the module will be setting up. 

In order to successfully set up your web servers, you must know the following information about your systems:

1. The IP addresses of both of the web servers;
2. The names of the nodes each web server will be on;
3. The ports the web servers are listening on; and
4. The IP address of the virtual server.

####Step One: Classifying your servers

In your site.pp file, enter the below code:

**TODO:Update**

~~~
node 'certname' {
netscaler_server { '1_10_server1':
  ensure  => present,
  address => '1.10.1.1',
  }
netscaler_service { '1_10_service1':
  ensure      => 'present',
  server_name => '1_10_server1',
  port        => '80',
  protocol    => 'HTTP',
  comments    => 'This is a comment'
}
netscaler_lbvserver { '1_10_lbvserver1':
  ensure       => 'present',
  service_type => 'HTTP',
  ip_address   => '1.10.1.2',
  port         => '8080',
  state        => true,
}
netscaler_lbvserver_service_binding { '1_10_lbvserver1/1_10_service1':
  ensure => 'present',
  weight => '100',
}
netscaler_rewritepolicy { '2_4_rewritepolicy_test1':
  ensure                  => 'present',
  action                  => 'NOREWRITE',
  comments                => 'comment',
  expression              => 'HTTP.REQ.URL.SUFFIX.EQ("")',
  undefined_result_action => 'DROP',
}
netscaler_csvserver { '2_4_csvserver_test1':
  ensure        => 'present',
  service_type  => 'HTTP',
  state         => true,
  ip_address    => '2.4.1.1',
  port          => '8080',
}
netscaler_csvserver_rewritepolicy_binding { '2_4_csvserver_test1/2_4_rewritepolicy_test1':
  ensure               => present,
  priority             => 1,
  invoke_vserver_label => '2_4_csvserver_test1',
  choose_type          => 'Request',
}
}
~~~


####Step Two: Run your Puppet master

Run the following to have the Puppet master apply your classifications and configure the NetScaler device: 

~~~
$ FACTER_url=https://<USERNAME>:<PASSWORD>@<NETSCALER1.EXAMPLE.COM> puppet device -v
~~~

If you do not run this command, clients will not be able to make requests to the web servers.

At this point, your basic web servers should be up and fielding requests.

###Tips and Tricks

####Basic Usage**TODO**

Once you've established a basic configuration, you can explore the providers and their allowed options by running `puppet resource <TYPENAME>` for each type. This will provide a starting point for seeing what's already on your NetScaler. If anything failed to set up properly, it will not show up when you run the command.

To begin with you can simply call the types from the proxy system.

**TODO:Update**
~~~
$ FACTER_url=https://admin:admin@netscaler1.example.com/ puppet resource netscaler_lbvserver
~~~

####Role and Profiles
The [above example](#set-up-two-loadbalanced-web-servers) is for setting up a simple configuration of two web servers. However, for anything more complicated, you will want to use the roles and profiles pattern when classifying nodes or devices for NetScaler.

####Custom HTTP monitors
If you have a '/Common/http_monitor (which is available by default), then when you are creating a /Common/custom_http_monitor you can simply use `parent_monitor => '/Common/http'` so that you don't have to duplicate all values.

##Reference

###Public Types

* [`netscaler_lbmonitor`](#type-netscaler_lbmonitor)
* [`netscaler_lbvserver`](#type-netscaler_lbvserver)
* [`netscaler_lbvserver_service_bind`](#type-netscaler_lbvserver_service_bind)
* [`netscaler_server`](#type-netscaler_server)
* [`netscaler_service`](#type-netscaler_service)
* [`netscaler_service_lbmonitor-bind`](#type-netscaler_service_lbmonitor-bind)


###Type: netscaler_lbmonitor
 
Manages loadbalancer monitoring on the NetScaler appliance.  If the service is domain-based, you must use the `add server` command to create the 'server' entry before you create the service. Then, specify the `server` parameter in the `add server` command.
 
####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`account_application_ids`
Specifies a list of Acct-Application-Id attribute value pairs (AVPs) for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers. A maximum of eight of AVPs are supported in a monitoring message.
 
Valid options: An AVP or an array of up to 8 AVPs
 
#####`account_session_id`
Specifies the Account Session ID to be used in Account Request Packet. Applicable to RADIUS_ACCOUNTING monitors.

Valid options: String
 
#####`account_type`
Sets the Account Type to be used in Account Request Packet. Applicable to RADIUS_ACCOUNTING monitors.
 
Valid options: Integer; maximum = 15 Default: 1
 
#####`action`
Specifies the action to perform when the response to an inline monitor (HTTP-INLINE) indicates that the service is down. A service monitored by an inline monitor is considered DOWN if the response code is not one of the codes that have been specified for the Response Code parameter.
 
The following options will have the following impact:
 
  * NONE - Takes no action. 
  * LOG - Logs the event in NSLOG or SYSLOG.
  * DOWN - Marks the service as being down and ensures no traffic is directed to the service until the configured down time has expired. Persistent connections to the service are terminated as soon as the service is marked as DOWN. The event is logged in NSLOG or SYSLOG.
 
Valid options: 'NONE', 'LOG', or 'DOWN' Default: 'SM_DOWN'
 
#####`application_name`
Sets the name of the application used to determine the state of the service. Applicable to CITRIX-XML-SERVICE monitors.

Valid options: String
 
#####`attribute`
Specifies the attribute to evaluate when the LDAP server responds to the query. Success or failure of the monitoring probe depends on whether the attribute exists in the response.

Valid options: String
 
#####`authentication_application_ids`
Specifies the list of Auth-Application-Id attribute value pairs (AVPs) for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers. A maximum of eight of these AVPs are supported in a monitoring CER message.
 
Valid options: An AVP or an array of up to 8 AVPs
 
#####`base_dn`
Sets the base distinguished name of the LDAP service, from where the LDAP server can begin the search for the attributes in the monitoring query. Required for LDAP service monitoring.

Valid options: String
 
#####`bind_dn`
Sets the distinguished name with which an LDAP monitor can perform the Bind operation on the LDAP server. Applicable to LDAP monitors.

Valid options: String
 
#####`called_station_id`
Sets the Called Station Id to be used in Account Request Packet. Applicable to RADIUS_ACCOUNTING monitors.

Valid options: String

#####`calling_station_id`
Sets the Calling Stations Id to be used in Account Request Packet. Applicable to RADIUS_ACCOUNTING monitors.

Valid options: String
 
#####`check_backend_services`
Enables monitoring of services running on storefront server. Storefront services are monitored by probing to a Windows service that runs on the Storefront server and exposes details of which storefront services are running.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.
 
#####`custom_header`
Specifies a custom header string to include in the monitoring probes.

Valid options: String
 
#####`database`
Specifies the name of the database to connect to during authentication.

Valid options: String
 
#####`destination_ip`
Sets the IP address of the service to send probes to. If the parameter is set to 0, the IP address of the server to which the monitor is bound is considered the destination IP address.

Valid options: IP address or '0'
 
#####`destination_port`
Specifies the TCP or UDP port to send the probe to. For most monitors, if the parameter is set to 0, the port number of the service to which the monitor is bound is considered the destination port. For a USER monitor, the destination port is the port number that is included in the HTTP request sent to the dispatcher. This parameter does not apply to PING monitors.

Valid options: Integers
 
#####`deviation`
Sets the time to add to the learned average response time in dynamic response time monitoring (DRTM). When a deviation is specified, your NetScaler appliance learns the average response time of bound services and adds the deviation to the average. The final value is then continually adjusted to accommodate response time variations over time. Specified in milliseconds, seconds, or minutes.
 
Valid options: Integer expressed in milliseconds, seconds, or minutes; maximum = 20939000 seconds.
 
#####`dispatcher_ip`
Sets the IP address of the dispatcher to send the probe to.

Valid options: IP address
 
#####`dispatcher_port`
Sets the port number on which the dispatcher listens for the monitoring probe.

Valid options: Integers
 
#####`domain`
Sets the domain in which the XenDesktop Desktop Delivery Controller (DDC) servers or Web Interface servers are present. Required by CITRIX-XD-DDC and CITRIX-WI-EXTENDED monitors for logging on to the DDC servers and Web Interface servers.

Valid options: String
 
#####`down_time`
Sets the time duration to wait before probing a service that has been marked as DOWN. Expressed in milliseconds, seconds, or minutes.
 
Valid option: Integer expressed in milliseconds, seconds, or minutes; minimum = 1 second and maximum = 20939000 seconds. Default: 30 seconds
 
#####`ensure`
Determines whether the loadbalancer monitoring service is present or absent.
 
Valid options: `present` or `absent`.
 
#####`expression`
Sets the default syntax expression that evaluates the database server's response to a MYSQL-ECV or MSSQL-ECV monitoring query. Must produce a Boolean result, as the result determines the state of the server. If the expression returns TRUE, the probe succeeds.
 
For example, if you want the appliance to evaluate the error message to determine the state of the server, use the rule 'MYSQL.RES.ROW(10) .TEXT_ELEM(2).EQ("MySQL")'.

Valid options: String
 
#####`failure_retries`
Sets the number of retries that must fail, out of the number specified for the `retries` parameter, for a service to be marked as DOWN. '0' means that all the retries must fail if the service is to be marked as DOWN.

For example, if the `retries` parameter is set to 10 and the `failure_retries` parameter is set to 6, out of the ten probes sent, at least six probes must fail if the service is to be marked as DOWN.
  
Valid options: Integer; maximum = 32. Default: 0
 
#####`file_name`
Sets the name of a file on the FTP server. Your NetScaler appliance monitors the FTP service by periodically checking the existence of the file on the server. Applicable to FTP-EXTENDED monitors.

Valid options: String
 
#####`filter`
Filters criteria for the LDAP query.

Valid options: String
 
#####`firmware_revision`
Sets the Firmware-Revision value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.

Valid options: Integer
 
#####`framed_ip`
Sets the source IP the packet will go out with. Applicable to RADIUS_ACCOUNTING monitors.

Valid options: IP address
 
#####`group_name`
Sets the name of a newsgroup available on the monitored NNTP service. Your NetScaler appliance periodically generates an NNTP query for the name of the newsgroup and evaluates the response. If the newsgroup is found on the server, the service is marked as UP. If the newsgroup does not exist or if the search fails, the service is marked as DOWN. Applicable to NNTP monitors.

Valid options: String
 
#####`host_ip`
Sets the Host-IP-Address value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers. If Host-IP-Address is not specified, the appliance inserts the mapped IP (MIP) address or subnet IP (SNIP) address from which the CER request (the monitoring probe) is sent.

Valid options: IP address
 
#####`http_request`
Specifies the HTTP request to send to the server (for example, "HEAD /file.html").

Valid options: String 
 
#####`inband_security_id`
Specifies the Inband-Security-Id for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.
 
Valid options: 'NO_INBAND_SECURITY' or 'TLS'
 
#####`interval`
Determines the time interval in seconds between two successive probes. Must be greater than the value of [`response_timeout`](#response_timeout).
 
Valid options: Integer expressed in seconds; minimum = 1 second and maximum = 20940000 seconds Default: 5 seconds

#####`ip_address`
Specifies the set of IP addresses expected in the monitoring response from the DNS server if the record type is A or AAAA. Applicable to DNS monitors.

Valid options: An array of IP addresses
 
#####`ip_tunnel`
Determines whether to send the monitoring probe to the loadbalancing service through an IP tunnel. A destination IP address must be specified.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF' Default: 'NO'

#####`kcd_account`
Specifices the KCD Account used by MSSQL monitor.

Valid options: String
 
#####`logon_agent_service_version`
Sets the version number of the Citrix Advanced Access Control Logon Agent. Required by the CITRIX-AAC-LAS monitor.

Valid options: String

#####`logon_point_name`
Specifies the name of the logon point that is configured for the Citrix Access Gateway Advanced Access Control software. Required if you want to monitor the associated login page or Logon Agent. Applicable to CITRIX-AAC-LAS and CITRIX-AAC-LOGINPAGE monitors.

Valid options: String

#####`lrtm`
Calculates the least response times for bound services. If this parameter is not enabled, the appliance does not learn the response times of the bound services. Also used for LRTM load balancing.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'

#####`max_forwards`
Sets the maximum number of hops that the SIP request used for monitoring can traverse to reach the server. Applicable only to SIP-UDP monitors.

Valid options: Integer; maximum = 255 Default: 1

#####`metric_table`
Specifies a metric table to bind metrics to.

Valid options: String

#####`name`
Specifies a name for the object.

Valid options: Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`nas_id`
Specifies the NAS-Identifier to send in the Access-Request packet. Applicable to RADIUS monitors.

Valid options: String
 
#####`nas_ip`
Sets the Network Access Server (NAS) IP address to use as the source IP address when monitoring a RADIUS server. Applicable to  RADIUS and RADIUS_ACCOUNTING monitors.

Valid options: IP Address

#####`net_profile`
Sets the name of the network profile.

Valid options: String
 
#####`origin_host`
Specifies the Origin-Host value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.

Valid options: String

#####`origin_realm`
Specifies the Origin-Realm value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.

Valid options: String

#####`password`
Sets the password required for logging on to the RADIUS, NNTP, FTP, FTP-EXTENDED, MYSQL, MSSQL, POP3, CITRIX-AG, CITRIX-XD-DDC, CITRIX-WI-EXTENDED, CITRIX-XNC-ECV or CITRIX-XDM servers. Used in conjunction with the user name specified for the [`user_name`](#user_name) parameter.

Valid options: String

#####`product_name`
Specifies the Product-Name value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.

Valid options: String

#####`protocol_version`
Specifies the version of MSSQL server to be monitored.

Valid options: '70', '2000', '2000SP1', '2005', '2008', '2008R2', '2012' Default: '70'

#####`query`
Specifies the domain name to resolve as part of monitoring the DNS service (for example, example.com).

Valid options: String

#####`query_type`
Sets the type of DNS record to send monitoring queries to. Set to 'Address' for querying A records, 'AAAA' for querying AAAA records, and 'Zone' for querying the SOA record.

Valid options: 'Address', 'Zone', or 'AAAA'

#####`radius_key`
Specifies the authentication key (shared secret text string) for RADIUS clients and servers to exchange. Applicable to RADIUS and RADIUS_ACCOUNTING monitors.

Valid options: String

#####`receive_string`
Specifies the string expected from the server for the service to be marked as UP. Applicable to TCP-ECV, HTTP-ECV, and UDP-ECV monitors.

Valid options: String
 
#####`resp_timeout_threshold`
Sets the response time threshold, specified as a percentage of the [`response_timeout`](#response_timeout) parameter. If the response to a monitor probe has not arrived when the threshold is reached, the NetScaler appliance generates an SNMP trap called monRespTimeoutAboveThresh. After the response time returns to a value below the threshold, the appliance generates a monRespTimeoutBelowThresh SNMP trap. For the traps to be generated, the "MONITOR-RTO-THRESHOLD" alarm must also be enabled.

Valid options: Integer; maximum = 100 Default: 1

#####`response_codes`
Sets the response codes that mark the service as UP. For any other response code, the action performed depends on the monitor type. HTTP monitors and RADIUS monitors mark the service as DOWN, while HTTP-INLINE monitors perform the action indicated by the [`action`](#action) parameter.

Valid options: String or array of strings

#####`response_timeout`
Sets the amount of time the appliance must wait before it marks a probe as FAILED. Must be less than the value specified for the [`interval`](interval) parameter.

Note: This parameter does not apply to UDP-ECV monitors that do not have a receive string configured. For UDP-ECV monitors with no receive string, probe failure is indicated by an ICMP port unreachable error received from the service.

Valid options: Integer; minimum = 1s and maximum = 20939000s Default: 2s
 
#####`retries`
Sets the maximum number of probes to send to establish the state of a service for which a monitoring probe failed.

Valid options: Integers; minimum = 1 and maximum = 127 Default: 3
 
#####`reverse`
Specifies whether to ,ark a service as DOWN instead of UP when probe criteria are satisfied, and as UP instead of DOWN when probe criteria are not satisfied.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF' Default: 'NO'
 
#####`rtsp_request`
Specifies the RTSP request to send to the server (for example, "OPTIONS *").

Valid options: String

#####`script_arguments`
Specifies the string of arguments for the script. The string is copied verbatim into the request.

Valid options: String

#####`script_name`
Sets the path and name of the script to execute. The script must be available on the NetScaler appliance, in the /nsconfig/monitors/ directory.

Valid options: String

#####`secondary_password`
Sets the secondary password that users might have to provide to log on to the Access Gateway server. Applicable to CITRIX-AG monitors.

Valid options: String

#####`secure`
Determines whether to use a secure SSL connection when monitoring a service. Applicable only to TCP-based monitors. The secure option cannot be used with a CITRIX-AG monitor, because a CITRIX-AG monitor uses a secure connection by default.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF' Default: 'NO'

#####`send_string`
Specifies the string to send to the service. Applicable to TCP-ECV, HTTP-ECV, and UDP-ECV monitors.

Valid options: String

#####`sid`
Sets the name of the service identifier used to connect to the Oracle database during authentication.

Valid options: String

#####`sip_method`
Specifies the SIP method to use for the query. Applicable only to SIP-UDP monitors.

Valid options: 'OPTIONS', 'INVITE', or 'REGISTER'

#####`sip_reg_uri`
Specifies the SIP user to be registered. Applicable only to SIP-UDP monitors with the  `sip_method` parameter set to 'REGISTER'.

Valid options: String

#####`sip_uri`
Specifies the SIP URI string to send to the service (for example, sip:sip.test). Applicable only to SIP-UDP monitors.

Valid options: String

#####`site_path`
Sets the URL of the logon page. For CITRIX-WEB-INTERFACE monitors: to monitor a dynamic page under the site path, terminate the site path with a slash (/). Applicable to CITRIX-WEB-INTERFACE, CITRIX-WI-EXTENDED and CITRIX-XDM monitors.

Valid options: String

#####`snmp_alert_retries`
Sets the number of consecutive probe failures after which the appliance generates an SNMP trap called monProbeFailed.

Valid options: Integer; maximum = 32

#####`snmp_community`
Sets the community name for SNMP monitors.

Valid options: String

#####`snmp_oid`
Sets the SNMP OID for SNMP monitors.

Valid options: String

#####`snmp_threshold`
Specifies the threshold for SNMP monitors.

Valid options: String

#####`snmp_version`
Sets the SNMP version to be used for SNMP monitors.

Valid options: 'V1' or 'V2'

#####`sql_query`
Specifies a SQL query for a MYSQL-ECV or MSSQL-ECV monitor. Sent to the database server after the server authenticates the connection.

Valid options: String

#####`state`
Sets the state of the monitor. The 'DISABLED' setting disables not only the monitor being configured, but all monitors of the same type until the parameter is set to ENABLED. If the monitor is bound to a service, the state of the monitor is not taken into account when the state of the service is determined.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'

#####`store_db`
Determines whether to store the database list populated with the responses to monitor probes. Used in database specific load balancing if MSSQL-ECV/MYSQL-ECV monitor is configured.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'

#####`store_name`    
Sets the store name. Applicable to STOREFRONT monitors.

Valid options: String

#####`storefront_account_service`
Determines whether to enable or disable probing for Account Service. Applicable only to Store Front monitors. Multi-tenancy configuration users may skip this parameter.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF' Default: 'YES'

#####`success_retries`
Specifies the number of consecutive successful probes required to transition a service's state from DOWN to UP.

Valid option: Integer; minimum = 1 and maximum = 32 Default: 1

#####`supported_vendor_ids`
Lists the Supported-Vendor-Id attribute value pairs (AVPs) for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers. A maximum eight of these AVPs are supported in a monitoring message.

Valid options: An AVP or an array of up to 8 AVPs

#####`tos`
Determines whether to probe the service by encoding the destination IP address in the IP TOS (6) bits.

Valid options:'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'
 
#####`tos_id`
Sets the TOS ID of the specified destination IP. Applicable only when the `tos` parameter is set.

Valid options: Integer; minimum = 1 and maximum = 63

#####`transparent`
Determines whether the monitor is bound to a transparent device, such as a firewall or router. The state of a transparent device depends on the responsiveness of the services behind it. If a transparent device is being monitored, a destination IP address must be specified. The probe is sent to the specified IP address by using the MAC address of the transparent device.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF' Default: 'NO'
 
#####`type`
Specifies type of monitor that you want to create.

Valid options: 'PING', 'TCP', 'HTTP', 'TCP-ECV', 'HTTP-ECV', 'UDP-ECV', 'DNS', 'FTP', 'LDNS-PING', 'LDNS-TCP', 'LDNS-DNS', 'RADIUS', 'USER', 'HTTP-INLINE', 'SIP-UDP', 'LOAD', 'FTP-EXTENDED', 'SMTP', 'SNMP', 'NNTP', 'MYSQL', 'MYSQL-ECV', 'MSSQL-ECV', 'ORACLE-ECV', 'LDAP', 'POP3', 'CITRIX-XML-SERVICE', 'CITRIX-WEB-INTERFACE', 'DNS-TCP', 'RTSP', 'ARP', 'CITRIX-AG', 'CITRIX-AAC-LOGINPAGE', 'CITRIX-AAC-LAS', 'CITRIX-XD-DDC', 'ND6', 'CITRIX-WI-EXTENDED', 'DIAMETER', 'RADIUS_ACCOUNTING', 'STOREFRONT', 'APPC', 'CITRIX-XNC-ECV', or 'CITRIX-XDM'

#####`user_name`
Specifies the user name with which to probe the RADIUS, NNTP, FTP, FTP-EXTENDED, MYSQL, MSSQL, POP3, CITRIX-AG, CITRIX-XD-DDC, CITRIX-WI-EXTENDED, CITRIX-XNC or CITRIX-XDM server.

Valid options: String

#####`validate_credentials`
Determines whether to validate the credentials of the Xen Desktop DDC server user. Applicable to CITRIX-XD-DDC monitors.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF' Default: 'NO'

#####`vendor_id`
Sets the vendor-ID value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.

Valid options: Integers

#####`vendor_specific_vendor_id`
Sets the vendor-ID to use in the Vendor-Specific-Application-Id grouped attribute-value pair (AVP) in the monitoring CER message. To specify Auth-Application-Id or Acct-Application-Id in Vendor-Specific-Application-Id, use vendorSpecificAuthApplicationIds or vendorSpecificAcctApplicationIds, respectively. Only one Vendor-Id is supported for all the Vendor-Specific-Application-Id AVPs in a CER monitoring message.

Valid options: Integers; minimum = 1

###Type: netscaler_lbvserver

Manage Load Balanced VServer on the NetScaler appliance.

#### Parameters

#####`appflow_logging`

Apply AppFlow logging to the virtual server. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', DISABLED', YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`authentication`

Enable or disable user authentication. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`authentication_401`

Enable or disable user authentication with HTTP 401 responses. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`authentication_fqdn`

Fully qualified domain name (FQDN) of the authentication virtual server to which the user must be redirected for authentication. Make sure that the Authentication parameter is set to ENABLED.

#####`authentication_profile_name`

Name of the authentication profile to be used when authentication is turned on.

#####`authentication_virtual_server_name`

Name of an authentication virtual server with which to authenticate users.

#####`backup_persistence_timeout`

Time period for which backup persistence is in effect.

Minimum value: 2
Maximum value: 1440

#####`backup_virtual_server`

Name of the backup virtual server to which to forward requests if the primary virtual server goes DOWN or reaches its spillover threshold.

#####`bypass_aaaa`

If this option is enabled while resolving DNS64 query AAAA queries are not sent to back end dns server. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`cacheable`

Route cacheable requests to a cache redirection virtual server. The load balancing virtual server can forward requests only to a transparent cache redirection virtual server that has an IP address and port combination of *:80, so such a cache redirection virtual server must be configured on the appliance. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`client_timeout`

Idle time, in seconds, after which a client connection is terminated. Accepts an integer. Maximum value: 31536000.

#####`comment`

Any comments that you might want to associate with the virtual server.

#####`connection_failover`

Mode in which the connection failover feature must operate for the virtual server. After a failover, established TCP connections and UDP packet flows are kept active and resumed on the secondary appliance. Clients remain connected to the same servers. Available settings function as follows:

  * STATEFUL - The primary appliance shares state information with the secondary appliance, in real time, resulting in some runtime processing overhead.
  * STATELESS - State information is not shared, and the new primary appliance tries to re-create the packet flow on the basis of the information contained in the packets it receives.
  * DISABLED - Connection failover does not occur.

#####`cookie_name`

Use this parameter to specify the cookie name for COOKIE peristence type. It specifies the name of cookie with a maximum of 32 characters. If not specified, cookie name is internally generated.

#####`data_length`

Length of the token to be extracted from the data segment of an incoming packet, for use in the token method of load balancing. The length of the token, specified in bytes, must not be greater than 24 KB. Applicable to virtual servers of type TCP.

Minimum value: 1
Maximum value: 100

#####`data_offset`

Offset to be considered when extracting a token from the TCP payload. Applicable to virtual servers, of type TCP, using the token method of load balancing. Must be within the first 24 KB of the TCP payload.
Maximum value: 25400

#####`database_specific_lb`

Enable database specific load balancing for MySQL and MSSQL service types. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`db_profile_name`

Name of the DB profile whose settings are to be applied to the virtual server.

#####`disable_primary_on_down`

If the primary virtual server goes down, do not allow it to return to primary status until manually enabled. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`dns64`

This argument is for enabling/disabling the dns64 on lbvserver. 
  Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.


#####`down_state_flush`

Flush all active transactions associated with a virtual server whose state transitions from UP to DOWN. Do not enable this option for applications that must complete their transactions. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`ensure`

The basic property that the resource should be in. Valid values are `present`, `absent`.

#####`health_threshold`

Threshold in percent of active services below which vserver state is made down. If this threshold is 0, vserver state will be up even if one bound service is up.

Minimum value: 0
Maximum value: 100

#####`http_profile_name`

Name of the HTTP profile whose settings are to be applied to the virtual server.

#####`icmp_virtual_server_response`

How the NetScaler appliance responds to ping requests received for an IP address that is common to one or more virtual servers. Available settings function as follows:

  * If set to PASSIVE on all the virtual servers that share the IP address, the appliance always responds to the ping requests.
  * If set to ACTIVE on all the virtual servers that share the IP address, the appliance responds to the ping requests if at least one of the virtual servers is UP. Otherwise, the appliance does not respond.
  * If set to ACTIVE on some virtual servers and PASSIVE on the others, the appliance responds if at least one virtual server with the ACTIVE setting is UP. Otherwise, the appliance does not respond.
  
  Note: This parameter is available at the virtual server level. A similar parameter, ICMP Response, is available at the IP address level, for IPv4 addresses of type VIP. To set that parameter, use the add ip command in the CLI or the Create IP dialog box in the GUI.

#####`ip_address`

The IPv4 or IPv6 address to assign to the virtual server.

#####`ip_mask`

IP mask, in dotted decimal notation, for the IP Pattern parameter. Can have leading or trailing non-zero octets (for example, 255.255.240.0 or 0.0.255.255). Accordingly, the mask specifies whether the first n bits or the last n bits of the destination IP address in a client request are to be matched with the corresponding bits in the IP pattern. The former is called a forward mask. The latter is called a reverse mask.

#####`ip_pattern`

IP address pattern, in dotted decimal notation, for identifying packets to be accepted by the virtual server. The IP Mask parameter specifies which part of the destination IP address is matched against the pattern.  Mutually exclusive with the IP Address parameter.

For example, if the IP pattern assigned to the virtual server is 198.51.100.0 and the IP mask is 255.255.240.0 (a forward mask), the first 20 bits in the destination IP addresses are matched with the first 20 bits in the pattern. The virtual server accepts requests with IP addresses that range from 198.51.96.1 to 198.51.111.254.  You can also use a pattern such as 0.0.2.2 and a mask such as 0.0.255.255 (a reverse mask).

If a destination IP address matches more than one IP pattern, the pattern with the longest match is selected, and the associated virtual server processes the request. For example, if virtual servers vs1 and vs2 have the same IP pattern, 0.0.100.128, but different IP masks of 0.0.255.255 and 0.0.224.255, a destination IP address of 198.51.100.128 has the longest match with the IP pattern of vs1. If a destination IP address matches two or more virtual servers to the same extent, the request is processed by the virtual server whose port number matches the port number in the request.

#####`layer2_parameters`

Use Layer 2 parameters (channel number, MAC address, and VLAN ID) in addition to the 4-tuple (<source IP>:<source port>::<destination IP>:<destination port>) that is used to identify a connection. Allows multiple TCP and non-TCP connections with the same 4-tuple to co-exist on the NetScaler appliance. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`lb_method`

Load balancing method.  The available settings function as follows:

  * ROUNDROBIN - Distribute requests in rotation, regardless of the load. Weights can be assigned to services to enforce weighted round robin distribution.
  * LEASTCONNECTION (default) - Select the service with the fewest connections.
  * LEASTRESPONSETIME - Select the service with the lowest average response time.
  * LEASTBANDWIDTH - Select the service currently handling the least traffic.
  * LEASTPACKETS - Select the service currently serving the lowest number of packets per second.
  * CUSTOMLOAD - Base service selection on the SNMP metrics obtained by custom load monitors.
  * LRTM - Select the service with the lowest response time. Response times are learned through monitoring probes. This method also takes the number of active connections into account.
  
Also available are a number of hashing methods, in which the appliance extracts a predetermined portion of the request, creates a hash of the portion, and then checks whether any previous requests had the same hash value. If it finds a match, it forwards the request to the service that served those previous requests. Following are the hashing methods:

  * URLHASH - Create a hash of the request URL (or part of the URL).
  * DOMAINHASH - Create a hash of the domain name in the request (or part of the domain name). The domain name is taken from either the URL or the Host header. If the domain name appears in both locations, the URL is preferred. If the request does not contain a domain name, the load balancing method defaults to LEASTCONNECTION.
  * DESTINATIONIPHASH - Create a hash of the destination IP address in the IP header.
  * SOURCEIPHASH - Create a hash of the source IP address in the IP header.
  * TOKEN - Extract a token from the request, create a hash of the token, and then select the service to which any previous requests with the same token hash value were sent.
  * SRCIPDESTIPHASH - Create a hash of the string obtained by concatenating the source IP address and destination IP address in the IP header.
  * SRCIPSRCPORTHASH - Create a hash of the source IP address and source port in the IP header.
  * CALLIDHASH - Create a hash of the SIP Call-ID header.

#####`lb_method_hash_length`

Number of bytes to consider for the hash value used in the URLHASH and DOMAINHASH load balancing methods.

Minimum value = 1
Maximum value = 4096

#####`lb_method_ipv6_mask_length`

Number of bits to consider in an IPv6 destination or source IP address, for creating the hash that is required by the DESTINATIONIPHASH and SOURCEIPHASH load balancing methods.

Minimum value = 1
Maximum value = 128

#####`lb_method_netmask`

IPv4 subnet mask to apply to the destination IP address or source IP address when the load balancing method is DESTINATIONIPHASH or SOURCEIPHASH. 

Minimum length = 1.

#####`listen_policy`

Default syntax expression identifying traffic accepted by the virtual server. Can be either an expression (for example, CLIENT.IP.DST.IN_SUBNET(192.0.2.0/24) or the name of a named expression. In the above example, the virtual server accepts all requests whose destination IP address is in the 192.0.2.0/24 subnet.

#####`listen_priority`

Integer specifying the priority of the listen policy. A higher number specifies a lower priority. If a request matches the listen policies of more than one virtual server the virtual server whose listen policy has the highest priority (the lowest priority number) accepts the request.

Maximum value: 101

#####`macmode_retain_vlan`

This option is used to retain vlan information of incoming packet when macmode is enabled. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`max_autoscale_members`

Maximum number of members expected to be present when vserver is used in Autoscale.

Maximum value: 5000

#####`min_autoscale_members`

Minimum number of members expected to be present when vserver is used in Autoscale.

Maximum value: 5000

#####`mssql_server_version`

For a load balancing virtual server of type MSSQL, the Microsoft SQL Server version. Set this parameter if you expect some clients to run a version different from the version of the database. This setting provides compatibility between the client-side and server-side connections by ensuring that all communication conforms to the server's version. Valid options: 70, 2000, 2000SP1, 2005, 2008, 2008R2, 2012.

#####`mysql_character_set`

Character set that the virtual server advertises to clients.

#####`mysql_protocol_version`

MySQL protocol version that the virtual server advertises to clients.

#####`mysql_server_capabilities`

Server capabilities that the virtual server advertises to clients.

#####`mysql_server_version`

MySQL server version string that the virtual server advertises to clients.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`net_profile_name`

Name of the network profile to associate with the virtual server. If you set this parameter, the virtual server uses only the IP addresses in the network profile as source IP addresses when initiating connections with servers.

#####`new_service_request_increment_interval`

Interval, in seconds, between successive increments in the load on a new service or a service whose state has just changed from DOWN to UP. A value of 0 (zero) specifies manual slow start.

Maximum value: 3600

#####`new_service_request_rate`

Number of requests, or percentage of the load on existing services, by which to increase the load on a new service at each interval in slow-start mode. A non-zero value indicates that slow-start is applicable. A zero value indicates that the global RR startup parameter is applied. Changing the value to zero will cause services currently in slow start to take the full traffic as determined by the LB method. Subsequently, any new services added will use the global RR factor.

#####`new_service_request_unit`

Units in which to increment load at each interval in slow-start mode. Possible values = PER_SECOND, PERCENT

#####`oracle_server_version`

Oracle server version. Valid options: 10G, 11G.

#####`persist_avp_no`

Persist AVP number for Diameter Persistency. In case this AVP is not defined in Base RFC 3588 and it is nested inside a Grouped AVP, define a sequence of AVP numbers (max 3) in order of parent to child. So say persist AVP number X is nested inside AVP Y which is nested in Z, then define the list as  Z Y X.

Minimum value: 1

#####`persistence_backup`

Backup persistence type for the virtual server. Becomes operational if the primary persistence mechanism fails. Valid options: SOURCEIP, NONE.

#####`persistence_ipv4_mask`

Persistence mask for IP based persistence types, for IPv4 virtual servers.

#####`persistence_ipv6_mask_length`

Persistence mask for IP based persistence types, for IPv6 virtual servers.

Minimum value: 1
Maximum value: 128

#####`persistence_timeout`

Time period for which a persistence session is in effect.

Maximum value: 1440

#####`persistence_type`

Type of persistence for the virtual server. Available settings function as follows:

  * SOURCEIP - Connections from the same client IP address belong to the same persistence session.
  * COOKIEINSERT - Connections that have the same HTTP Cookie, inserted by a Set-Cookie directive from a server, belong to the same persistence session.
  * SSLSESSION - Connections that have the same SSL Session ID belong to the same persistence session.
  * CUSTOMSERVERID - Connections with the same server ID form part of the same session. For this persistence type, set the Server ID (CustomServerID) parameter for each service and configure the Rule parameter to identify the server ID in a request.
  * RULE - All connections that match a user defined rule belong to the same persistence session.
  * URLPASSIVE - Requests that have the same server ID in the URL query belong to the same persistence session. The server ID is the hexadecimal representation of the IP address and port of the service to which the request must be forwarded. This persistence type requires a rule to identify the server ID in the request.
  * DESTIP - Connections to the same destination IP address belong to the same persistence session.
  * SRCIPDESTIP - Connections that have the same source IP address and destination IP address belong to the same persistence session.
  * CALLID - Connections that have the same CALL-ID SIP header belong to the same persistence session.
  * RTSPSID - Connections that have the same RTSP Session ID belong to the same persistence session.

#####`port`

Port number for the virtual server.

#####`priority_queuing`

Use priority queuing on the virtual server. based persistence types, for IPv6 virtual servers. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`process_local`

By turning on this option packets destined to a vserver in a cluster will not under go any steering. Turn this option for single packet request response mode or when the upstream device is performing a proper RSS for connection based distribution. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`provider`

The specific backend to use for this `netscaler_lbvserver` resource. You will seldom need to specify this --- Puppet will usually discover the appropriate provider for your platform.Available providers are: rest.

#####`push`

Process traffic with the push virtual server that is bound to this load balancing virtual server. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`push_label_expression`

Expression for extracting a label from the server's response. Can be either an expression or the name of a named expression.

#####`push_multiple_clients`

Allow multiple Web 2.0 connections from the same client to connect to the virtual server and expect updates. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`push_virtual_server_name`

Name of the load balancing virtual server, of type PUSH or SSL_PUSH, to which the server pushes updates received on the load balancing virtual server that you are configuring.

#####`range`

Number of IP addresses that the appliance must generate and assign to the virtual server. The virtual server then functions as a network virtual server, accepting traffic on any of the generated IP addresses. The IP addresses are generated automatically, as follows:

* For a range of n, the last octet of the address specified by the IP Address parameter increments n-1 times.
* If the last octet exceeds 255, it rolls over to 0 and the third octet increments by 1.
  
Note: The Range parameter assigns multiple IP addresses to one virtual server. To generate an array of virtual servers, each of which owns only one IP address, use brackets in the IP Address and Name parameters to specify the range. For example:
  
~~~
add lb vserver my_vserver[1-3] HTTP 192.0.2.[1-3] 80
~~~

Minimum value: 1
Maximum value: 254

#####`recursion_available`

When set to 'YES', this option causes the DNS replies from this vserver to have the RA bit turned on. Typically one would set this option to YES, when the vserver is load balancing a set of DNS servers that support recursive queries. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`redirect_port_rewrite`

Rewrite the port and change the protocol to ensure successful HTTP redirects from services. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`redirect_url`

URL to which to redirect traffic if the virtual server becomes unavailable.

**WARNING:** Make sure that the domain in the URL does not match the domain specified for a content switching policy. If it does, requests are continuously redirected to the unavailable virtual server.

#####`redirection_mode`

Redirection mode for load balancing. Available settings function as follows:

* IP - Before forwarding a request to a server, change the destination IP address to the server's IP address.
* MAC - Before forwarding a request to a server, change the destination MAC address to the server's MAC address.  The destination IP address is not changed. MAC-based redirection mode is used mostly in firewall load balancing deployments.
* IPTUNNEL - Perform IP-in-IP encapsulation for client IP packets. In the outer IP headers, set the destination IP address to the IP address of the server and the source IP address to the subnet IP (SNIP). The client IP packets are not modified. Applicable to both IPv4 and IPv6 packets.
* TOS - Encode the virtual server's TOS ID in the TOS field of the IP header.

You can use either the IPTUNNEL or the TOS option to implement Direct Server Return (DSR).

#####`response_rule`

Default syntax expression specifying which part of a server's response to use for creating rule based persistence sessions (persistence type RULE). Can be either an expression or the name of a named expression.

Example:

~~~  HTTP.RES.HEADER("setcookie").VALUE(0).TYPECAST_NVLIST_T('=',';').VALUE("server1").
~~~

#####`rhi_state`

Route Health Injection (RHI) functionality of the NetSaler appliance for advertising the route of the VIP address associated with the virtual server. When Vserver RHI Level (RHI) parameter is set to VSVR_CNTRLD, the following are different RHI behaviors for the VIP address on the basis of RHIstate (RHI STATE) settings on the virtual servers associated with the VIP address:

* If you set RHI STATE to PASSIVE on all virtual servers, the NetScaler ADC always advertises the route for the VIP address.
* If you set RHI STATE to ACTIVE on all virtual servers, the NetScaler ADC advertises the route for the VIP address if at least one of the associated virtual servers is in UP state.
* If you set RHI STATE to ACTIVE on some and PASSIVE on others, the NetScaler ADC advertises the route for the VIP address if at least one of the associated virtual servers, whose RHI STATE set to ACTIVE, is in UP state.

#####`rtsp_natting`

Use network address translation (NAT) for RTSP data connections. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`rule`

Expression, or name of a named expression, against which traffic is evaluated. Written in the classic or default syntax.

Note: Maximum length of a string literal in the expression is 255 characters. A longer string can be split into smaller strings of up to 255 characters each, and the smaller strings concatenated with the + operator. For example, you can create a 500-character string as follows: '"<string of 255 characters>" + "<string of 245 characters>"'.

The following requirements apply only to the NetScaler CLI:
  
* If the expression includes one or more spaces, enclose the entire expression in double quotation marks.
* If the expression itself includes double quotation marks, escape the quotations by using the  character.
* Alternatively, you can use single quotation marks to enclose the rule, in which case you do not have to escape the double quotation marks.

#####`service_type`

Protocol used by the service (also called the service type). Valid options: HTTP, FTP, TCP, UDP, SSL, SSL_BRIDGE, SSL_TCP, DTLS, NNTP, DNS, DHCPRA, ANY, SIP_UDP, DNS_TCP, RTSP, PUSH, SSL_PUSH, RADIUS, RDP, MYSQL, MSSQL, DIAMETER, SSL_DIAMETER, TFTP, ORACLE.

#####`sessionless`

Perform load balancing on a per-packet basis, without establishing sessions. Recommended for load balancing of intrusion detection system (IDS) servers and scenarios involving direct server return (DSR), where session information is unnecessary. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`skip_persistency`

This argument decides the behavior incase the service which is selected from an existing persistence session has reached threshold. Valid options: Bypass, ReLb, None.

#####`spillover_backup_action`

Action to be performed if spillover is to take effect, but no backup chain to spillover is usable or exists. Valid options: DROP, ACCEPT, REDIRECT.

#####`spillover_method`

Type of threshold that, when exceeded, triggers spillover. Available settings function as follows:

* CONNECTION - Spillover occurs when the number of client connections exceeds the threshold.
* DYNAMICCONNECTION - Spillover occurs when the number of client connections at the virtual server exceeds the sum of the maximum client (Max Clients) settings for bound services. Do not specify a spillover threshold for this setting, because the threshold is implied by the Max Clients settings of bound services.
* BANDWIDTH - Spillover occurs when the bandwidth consumed by the virtual server's incoming and outgoing traffic exceeds the threshold.
* HEALTH - Spillover occurs when the percentage of weights of the services that are UP drops below the threshold. For example, if services svc1, svc2, and svc3 are bound to a virtual server, with weights 1, 2, and 3, and the spillover threshold is 50%, spillover occurs if svc1 and svc3 or svc2 and svc3 transition to DOWN.
* NONE - Spillover does not occur.

#####`spillover_persistence`

If spillover occurs, maintain source IP address based persistence for both primary and backup virtual servers. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`spillover_persistence_timeout`

Timeout for spillover persistence, in minutes.

Minimum value: 2
Maximum value: 1440

#####`spillover_threshold`

Threshold at which spillover occurs. Specify an integer for the CONNECTION spillover method, a bandwidth value in kilobits per second for the BANDWIDTH method (do not enter the units), or a percentage for the HEALTH method (do not enter the percentage symbol).

Minimum value: 1
Maximum value: 4294967287

#####`state`

State of the load balancing virtual server. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`sure_connect`

Use SureConnect on the virtual server. Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`tcp_profile_name`

Name of the TCP profile whose settings are to be applied to the virtual server.

#####`tos_id`

TOS ID of the virtual server. Applicable only when the load balancing redirection mode is set to TOS.

Minimum value: 1
Maximum value: 63

#####`traffic_domain`

Integer value that uniquely identifies the traffic domain in which you want to configure the entity. If you do not specify an ID, the entity becomes part of the default traffic domain, which has an ID of 0.

Minimum value: 0
Maximum value: 4094

#####`vip_header_name`

Name for the inserted header. The default name is vip-header.

#####`virtual_server_ip_port_insertion`

Insert an HTTP header, whose value is the IP address and port number of the virtual server, before forwarding a request to the server. The format of the header is <vipHeader>: <virtual server IP address>_<port number >, where vipHeader is the name that you specify for the header. If the virtual server has an IPv6 address, the address in the header is enclosed in brackets ([ and ]) to separate it from the port number. If you have mapped an IPv4 address to a virtual server's IPv6 address, the value of this parameter determines which IP address is inserted in the header, as follows:

* VIPADDR - Insert the IP address of the virtual server in the HTTP header regardless of whether the virtual server has an IPv4 address or an IPv6 address. A mapped IPv4 address, if configured, is ignored.
* V6TOV4MAPPING - Insert the IPv4 address that is mapped to the virtual server's IPv6 address. If a mapped IPv4 address is not configured, insert the IPv6 address.
* OFF - Disable header insertion.

###Type: netscaler_lbserver_service_bind

Manage a binding between a loadbalancing vserver and a service.

#### Parameters

#####`ensure`

The basic property that the resource should be in. Valid values are `present`, `absent`.

#####`name`

lbvserver_name/service_name

#####`provider`

The specific backend to use for this `netscaler_lbvserver_service_bind` resource. You will seldom need to specify this --- Puppet will usually discover the appropriate provider for your platform. Available providers are: rest.

#####`weight`

Weight to assign to the specified service. Values can match `/^\d+$/`.

Min = 1
Max = 100


###Type: netscaler_server

Manages basic NetScaler server objects, either IP address based servers or domain-based servers.
 
####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.
 
#####`address`
Specifies the domain name, IPv4 address, or IPv6 address of the server.

Valid options: 'ipv4', 'ipv6', or 'domain name'

#####`comments`
Provides any necessary or additional information about the server.

Valid options: String
 
#####`disable_wait_time`
Specifies a wait time when disabling a server object. During the wait time, the server object continues to handle established connections but rejects new connections.
 
Valid options: '/\d+/'.
 
#####`ensure`
Determines whether the server object is present or absent.
 
Valid values are 'present', 'absent'
 
#####`graceful_shutdown`
Enables graceful shutdown of the server, in which the system will wait for all outstanding connections to the server to be closed before disabling it.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'
 
#####`ipv6_domain`
Supports IPv6 addressing mode. If you configure a server with the IPv6 addressing mode, you cannot use the server in the IPv4 addressing mode

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'
 
#####`name`
Specifies the name for the server. 

Valid options: Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters
 
#####`resolve_retry`
Sets the time, in seconds, the NetScaler appliance must wait after DNS resolution fails before sending the next DNS query to resolve the domain name.

Valid options: Integer; maximum = 20939 and minimum = 5 Default: 5
 
#####`state`
Sets the state of the server.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'
   
#####`traffic_domain_id`
Specifies the integer value that uniquely identifies the traffic domain in which you want to configure the entity. If you do not specify an ID, the entity becomes part of the default traffic domain.
 
Valid options: Integer; minimum = 0 and maximum = 4096 Default: 0
 
#####`translation_ip_address`
Specifies the IP address used to transform the server's DNS-resolved IP address.

Valid options: IP address
 
#####`translation_mask`
Sets the netmask of the translation IP. 

Valid options: IP netmask

###Type: netscaler_service

Manages service representation objects for NetScaler server entries. If the service is domain-based, you must use the `add server` command to create the 'server' entry before you create the service. Then, specify the server parameter in the `add server` command.
 
####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.
 
#####`access_down`
Determines whether to use Layer 2 mode to bridge the packets sent to the service if it is marked as DOWN. If the service is DOWN and this parameter is disabled, the packets are dropped.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'
 
#####`appflow_logging`
Enables logging of AppFlow information.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'
 
#####`cache_type`
Specifies the cache type supported by the cache server.

Valid options: 'SERVER', 'TRANSPARENT', 'REVERSE', or 'FORWARD'
 
#####`cacheable`
Uses the transparent cache redirection virtual server to forward requests to the cache server. May not be specified if `cache_type` is 'TRANSPARENT', 'REVERSE', or 'FORWARD'.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'
 
#####`clear_text_port`
Sets the port to which clear text data must be sent after the appliance decrypts incoming SSL traffic. Applicable to transparent SSL services.

Valid options: Integer
 
#####`client_idle_timeout`
Specifies the time, in seconds, after which to terminate an idle client connection.
 
Valid options: Integer; max = 31536000s
 
#####`client_ip`
Determines whether to insert an HTTP header with the client's IPv4 or IPv6 address as its value before forwarding a request to the service. Use if the server needs the client's IP address for security, accounting, or other purposes, and setting the `use_source_ip` parameter is not a viable option.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'
   
#####`client_ip_header`
Specifies the name for the HTTP header whose value must be set to the IP address of the client. Used with the `client_ip` parameter. 

If you set `client_ip` and you do not specify a name for the header, the appliance uses the header name specified for the global `client_ip_header` parameter. If the global `client_ip_header` parameter is not specified, the appliance inserts a header with the name "client-ip."

Valid options: Strings
 
#####`client_keepalive`
Enables client keep-alive for the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'
   
#####`comments`
Provides any necessary or additional information about the service.

Valid options: String
 
#####`down_state_flush`
Flushes all active transactions associated with a service whose state transitions from UP to DOWN. Do not enable this option for applications that must complete their transactions.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'
 
#####`ensure`
Determines whether the service is present or absent.
 
Valid options: 'present' or 'absent'
 
#####`graceful_shutdown`
Enables graceful shutdown of the server, meaning the system will wait for all outstanding connections to this server to be closed before disabling it.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'
 
#####`hash_id`
Specifies a numerical identifier to be used by hash-based load balancing methods. Must be unique for each service.
 
Valid options: Integer; minimum = 1
 
#####`health_monitoring`
Monitors the health of this service. Enabling this parameter sends probes to check the health of the service. Disabling this parameter means no probes are sent to check the health of the service, and the appliance shows the service as UP at all times.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'
 
#####`max_bandwidth`
Sets the maximum bandwidth, in Kbps, allocated to the service.
 
Valid options: Integers; maximum = 4294967287
 
#####`max_clients`
Sets the maximum number of simultaneous open connections to the service.
 
Valid options: Integers; maximum = 4294967294
 
#####`max_requests`
Sets the maximum number of requests that can be sent on a persistent connection to the service. Connection requests beyond this value are rejected.
 
Valid options: Integers; maximum = 65535
 
#####`monitor_threshold`
Specifies the minimum sum of weights of the monitors that are bound to this service. Used to determine whether to mark a service as UP or DOWN.
 
Valid options: Integers; maximum = 65535
 
#####`name`
Specifies the name for the service. 

Valid options: Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters
 
#####`port`
*Required.* Specifies the port number of the service.

Valid options: '*' or Integers
 
#####`protocol`
*Required.* Specifies the protocol in which data is exchanged with the service.

Valid options: 'HTTP', 'FTP', 'TCP', 'UDP', 'SSL', 'SSL_BRIDGE', 'SSL_TCP', 'DTLS', 'NNTP', 'RPCSVR', 'DNS', 'ADNS', 'SNMP', 'RTSP', 'DHCPRA', 'ANY', 'SIP_UDP', 'DNS_TCP', 'ADNS_TCP', 'MYSQL', 'MSSQL', 'ORACLE', 'RADIUS', 'RDP', 'DIAMETER', 'SSL_DIAMETER', or 'TFTP' 

#####`server_id`
Specifies a unique identifier for the service. Used when the persistency type for the virtual server is set to 'Custom Server ID'.

Valid options: String
 
#####`server_idle_timeout`
Sets the time, in seconds, after which to terminate an idle server connection.
 
Valid options: Integers; maximum = 31536000
 
#####`server_name`
*Required.* Specifies the name of the server that hosts the service.

Valid options: String
 
#####`state`
Sets the state of the node resource.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'
 
#####`sure_connect`
Sets the state of SureConnect for the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'
 
#####`surge_protection`
Enables surge protection for the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'
 
#####`tcp_buffering`
Enables TCP buffering for the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'
 
#####`traffic_domain_id`
Specifies the integer value that uniquely identifies the traffic domain in which you want to configure the entity. If you do not specify an ID, the entity becomes part of the default traffic domain.

Valid options: Integer; minimum = 0 and maximum = 4096
 
#####`use_proxy_port`
Uses the proxy port as the source port when initiating connections with the server. Disabling this parameter means the client-side connection port is used as the source port for the server-side connection. This parameter is available only when the `use_source_ip` parameter is enabled.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'
 
#####`use_source_ip`
Uses the client's IP address as the source IP address when initiating a connection to the server. When creating a service, if you do not set this parameter, the service inherits the global Use Source IP setting (available in the enable ns mode and disable ns mode CLI commands, or in the System > Settings > Configure modes > Configure Modes dialog box). However, you can override this setting after you create the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

###Type: netscaler_service_lbmonitor_bind
 
Manages a binding between a NetScaler service representation object and a loadbalancing monitor.
 
####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.
 
#####`ensure`
Determines whether the monitor-service binding is present or absent.

Valid values are `present` or `absent`.
 
#####`name`
Specifies the name for the monitor-service binding.

Valid options: Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`passive`
Sets the monitor as passive. A passive monitor does not remove service from LB decision when the threshold is breached.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`state`
Determines whether the bound monitor is enabled or disabled.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'

#####`weight`
Specifies the weight to assign to the monitor-service binding. When a monitor is UP, the weight assigned to its binding with the service determines how much the monitor contributes toward keeping the health of the service above the value configured for the [`monitor_threshold`](#monitor_threshold) parameter.

Valid options /^\d+$/ ; minimum = 1 and maximum = 100.

###netscaler_lbvserver_service_bind

Manages a binding between a loadbalancing vserver and a service.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`
Determines whether the lbvserver-service binding is present or absent.

Valid values are `present` or `absent`.

#####`name`
Specifies the name for the lbvserver-service binding.

TODO lbvserver_name/service_name

#####`provider`

The specific backend to use for this `netscaler_lbvserver_service_bind` resource. You will seldom need to specify this --- Puppet will usually discover the appropriate provider for your platform. 

Available providers are:

* `rest`

#####`weight`
Specifies the weight to assign to the specified service.

Valid options /^\d+$/ ; minimum = 1 and maximum = 100.