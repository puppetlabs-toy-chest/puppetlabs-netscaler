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
[bigip]
type netscaler
url https://<USERNAME>:<PASSWORD>@<IP ADDRESS OF BIGIP>/
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

**TODO:Update for NetScaler**
~~~
node bigip {
f5_node { '/Common/WWW_Server_1':
  ensure                   => 'present',
  address                  => '172.16.226.10',
  description              => 'WWW Server 1',
  availability_requirement => 'all',
  health_monitors          => ['/Common/icmp'],
}->
f5_node { '/Common/WWW_Server_2':
  ensure                   => 'present',
  address                  => '172.16.226.11',
  description              => 'WWW Server 2',
  availability_requirement => 'all',
  health_monitors          => ['/Common/icmp'],
}->
f5_pool { '/Common/puppet_pool':
  ensure                    => 'present',
  members                   => [{ name => '/Common/WWW_Server_1', port => '80'}, { name => '/Common/WWW_Server_1', port => '80'}],
  availability_requirement  => 'all',
  health_monitors           => ['/Common/http_head_f5'],
}->
f5_virtualserver { '/Common/puppet_vs':
  ensure                    => 'present',
  provider                  => 'standard',
  default_pool              => '/Common/puppet_pool',
  destination_address       => '192.168.80.100',
  destination_mask          => '255.255.255.255',
  http_profile              => '/Common/http',
  service_port              => '80',
  protocol                  => 'tcp',
  source                    => '0.0.0.0/0',
  vlan_and_tunnel_traffic   => {'enabled' => ['/Common/Client']},
}
}
~~~

**The order of your resources is extremely important.** You must first establish your two web servers. In the code above, they are **TODO:Update this**`f5_node { '/Common/WWW_Server_1'...` and `f5_node { '/Common/WWW_Server_2'...`. Each have the minimum number of parameters possible, and are set up with a health monitor that will ping each server directly to make sure it is still responsive. 

Then you establish the pool of servers. The pool is also set up with the minimum number of parameters. The health monitor for the pool will run an https request to see that a webpage is returned.

The virtual server brings your setup together. Your virtual server **must** have a `provider` assigned. 

####Step Two: Run your Puppet master

Run the following to have the Puppet master apply your classifications and configure the NetScaler device: 

~~~
$ FACTER_url=https:/<USERNAME>:<PASSWORD>@<IP ADDRESS OF BIGIP> puppet device -v
~~~

If you do not run this command, clients will not be able to make requests to the web servers.

At this point, your basic web servers should be up and fielding requests.

###Tips and Tricks

####Basic Usage**TODO**

Once you've established a basic configuration, you can explore the providers and their allowed options by running `puppet resource <TYPENAME>` for each type. This will provide a starting point for seeing what's already on your NetScaler. If anything failed to set up properly, it will not show up when you run the command.

To begin with you can simply call the types from the proxy system.

**TODO:Update**
```
$ FACTER_url=https://admin:admin@f5.hostname/ puppet resource f5_node
```

You can change a property by hand this way, too.

**TODO:Update**
```
$ FACTER_url=https://admin:admin@f5.hostname/ puppet resource f5_user node ensure=absent
``` 

####Role and Profiles
The [above example](#set-up-two-loadbalanced-web-servers) is for setting up a simple configuration of two web servers. However, for anything more complicated, you will want to use the roles and profiles pattern when classifying nodes or devices for NetScaler.

####Custom HTTP monitors
If you have a '/Common/http_monitor (which is available by default), then when you are creating a /Common/custom_http_monitor you can simply use `parent_monitor => '/Common/http'` so that you don't have to duplicate all values.

##Reference

###Public Types

* [`netscaler_lbmonitor`](#type-netscaler_monitor)
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

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'

###Type: netscaler_service_lbmonitor_bind
 
Manages a binding between a NetScaler service representation object and a loadbalancing monitor.
 
####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.
 
#####`ensure`
Determines whether the monitor-service binding is present or absent.

Valid values are `present` or `absent`.
 
#####`name`
Specifies the name for the monitor-service binding.

Valid options: Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters

#####`passive`
Sets the monitor as passive. A passive monitor does not remove service from LB decision when the threshold is breached.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'

#####`state`
Determines whether the bound monitor is enabled or disabled.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'

#####`weight`
Specifies the weight to assign to the monitor-service binding. When a monitor is UP, the weight assigned to its binding with the service determines how much the monitor contributes toward keeping the health of the service above the value configured for the [`monitor_threshold`](#monitor_threshold) parameter.

Valid options /^\d+$/ ; minimum = 1 and maximum = 100