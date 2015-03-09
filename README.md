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

Before you can use the netscaler module, you must create a proxy system able to run `puppet device`.  In order to do so, you will have a Puppet master and a Puppet agent as usual, and the agent will be the "proxy system" for the puppet device subcommand.

**NOTE: puppet device was designed to interface with the admin interface to run commands to implement type/provider. puppet device allows you to write a resource to talk to the device (ask Hunter about specific implementation) translates parts of the module (providers and such)into network calls

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
 
Manages loadbalancer monitoring on the NetScaler appliance.  If the service is domain-based, you must use the `add server` command to create the server entry before creating the service. You must specify the Server parameter? in the command add server XTODO:?
 
#### Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

####`account_application_ids`
Specifies a list of Acct-Application-Id attribute value pairs (AVPs) for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers. A maximum of eight of AVPs are supported in a monitoring message.
 
Valid options:**TODO**; maximum = 4294967295 **TODO: Do 8 AVPs = this max?**
 
####`account_session_id`
Specifies the Account Session ID to be used in Account Request Packet. Applicable to monitors of type RADIUS_ACCOUNTING.**TODO: What is this?**

Valid options: **TODO**
 
####`account_type`
Sets the Account Type to be used in Account Request Packet. Applicable to monitors of type RADIUS_ACCOUNTING.**TODO: What is this?**
 
Valid options: Integer; maximum = 15. Default: 1
 
####`action`
Specifies the action to perform when the response to an inline monitor (HTTP-INLINE) indicates that the service is down. A service monitored by an inline monitor is considered DOWN if the response code is not one of the codes that have been specified for the Response Code parameter.
 
The following options will have the following impact:
 
  * NONE - Takes no action. The `show service` command and the `show lb monitor`**TODO: Are these commands in the usual sense?** command will indicate the total number of responses that were checked and the number of consecutive error responses received after the last successful probe.
  * LOG - Logs the event in NSLOG or SYSLOG.
  * DOWN - Marks the service as being down and ensures no traffic is directed to the service until the configured down time has expired. Persistent connections to the service are terminated as soon as the service is marked as DOWN. The event is logged in NSLOG or SYSLOG.
 
Valid options: NONE, LOG, DOWN. Default: SM_DOWN
 
####`application_name`
Sets the name of the application used to determine the state of the service. Applicable to monitors of type CITRIX-XML-SERVICE.**TODO: What is this? Maybe change to Applicable to CITRIX-whatever monitors?**
 
####`attribute`
Specifies the attribute to evaluate when the LDAP server responds to the query. Success or failure of the monitoring probe depends on whether the attribute exists in the response. Optional.**TODO: Optional vs. required status in the whole module**
 
####`authentication_application_ids`
Specifies the list of Auth-Application-Id attribute value pairs (AVPs) for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers. A maximum of eight of these AVPs are supported in a monitoring CER message.
 
Valid options:**TODO**; maximum = 4294967295 **TODO: Do 8 AVPs = this max?**
 
####`base_dn`
Sets the base distinguished name of the LDAP service, from where the LDAP server can begin the search for the attributes in the monitoring query.**TODO:What?** Required for LDAP service monitoring.

Valid options: **TODO**
 
####`bind_dn`
Sets the distinguished name with which an LDAP monitor can perform the Bind operation on the LDAP server. Optional.**TODO** Applicable to LDAP monitors.

Valid options: **TODO**
 
####`called_station_id`
Sets the Called Station Id to be used in Account Request Packet. Applicable to RADIUS_ACCOUNTING monitors.

Valid options: **TODO**

####`calling_station_id`
Sets the Calling Stations Id to be used in Account Request Packet. Applicable to RADIUS_ACCOUNTING monitors.

Valid options: **TODO**
 
####`check_backend_services`
Enables monitoring of services running on storefront server. Storefront services are monitored by probing to a Windows service that runs on the Storefront server and exposes details of which storefront services are running.

Valid options: **TODO**
 
####`custom_header`
Specifies a custom header string to include in the monitoring probes.

Valid options: String. Default: **TODO**
 
####`database`
Specifies the name of the database to connect to during authentication.

Valid options: **TODO**
 
####`destination_ip`
Sets the IP address of the service to send probes to. If the parameter is set to 0, the IP address of the server to which the monitor is bound is considered the destination IP address.

Valid options: **TODO**
 
####`destination_port`
Specifies the TCP or UDP port to send the probe to. For most monitors, if the parameter is set to 0, the port number of the service to which the monitor is bound is considered the destination port. For a USER monitor, the destination port is the port number that is included in the HTTP request sent to the dispatcher. This parameter does not apply to PING monitors.

Valid options: **TODO**
 
####`deviation`
Sets the time to add to the learned average response time in dynamic response time monitoring (DRTM). When a deviation is specified, your NetScaler appliance learns the average response time of bound services and adds the deviation to the average. The final value is then continually adjusted to accommodate response time variations over time. Specified in milliseconds, seconds, or minutes.
 
Valid options: Integer expressed in milliseconds, seconds, or minutes; maximum = 20939000.
 
####`dispatcher_ip`
Sets the IP address of the dispatcher to which to send the probe. **TODO**

Valid options: **TODO**
 
####`dispatcher_port`
Sets the port number on which the dispatcher listens for the monitoring probe.

Valid options: **TODO**
 
####`domain`
Sets the domain in which the XenDesktop Desktop Delivery Controller (DDC) servers or Web Interface servers are present. Required by CITRIX-XD-DDC and CITRIX-WI-EXTENDED monitors for logging on to the DDC servers and Web Interface servers.

Valid options: **TODO**
 
####`down_time`
Sets the time duration to wait before probing a service that has been marked as DOWN. Expressed in milliseconds, seconds, or minutes.
 
Valid option: Integer expressed in milliseconds, seconds, or minutes; minimum = 1 and maximum = 20939000. Default: 30
 
####`ensure`
Determines whether the loadbalancer monitoring service is present or absent
 
Valid options: `present` or `absent`. Default:**TODO**
 
####`expression`
Sets the default syntax expression that evaluates the database server's response to a MYSQL-ECV or MSSQL-ECV monitoring query. Must produce a Boolean result, as the result determines the state of the server. If the expression returns TRUE, the probe succeeds.
 
For example, if you want the appliance to evaluate the error message to determine the state of the server, use the rule 'MYSQL.RES.ROW(10) .TEXT_ELEM(2).EQ("MySQL")'.

Valid options: Boolean**?**
 
####`failure_retries`
Sets the number of retries that must fail, out of the number specified for the Retries parameter, for a service to be marked as DOWN. For example, if the Retries parameter is set to 10 and the Failure Retries parameter is set to 6, out of the ten probes sent, at least six probes must fail if the service is to be marked as DOWN. The default value of 0 means that all the retries must fail if the service is to be marked as DOWN.
 
Valid options: Integer; maximum = 32.
 
####`file_name`
Sets the name of a file on the FTP server. Your NetScaler appliance monitors the FTP service by periodically checking the existence of the file on the server. Applicable to FTP-EXTENDED monitors.

Valid options: **TODO**
 
####`filter`
Filters criteria for the LDAP query. Optional.**TODO?**

Valid options: **TODO**
 
####`firmware_revision`
Sets the Firmware-Revision value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.

Valid options: **TOSO**
 
####`framed_ip`
Sets the source IP the packet will go out with. Applicable to RADIUS_ACCOUNTING monitors.

Valid options: **TODO**
 
####`group_name`
Sets the name of a newsgroup available on the monitored NNTP service. Your NetScaler appliance periodically generates an NNTP query for the name of the newsgroup and evaluates the response. If the newsgroup is found on the server, the service is marked as UP. If the newsgroup does not exist or if the search fails, the service is marked as DOWN. Applicable to NNTP monitors.

Valid options: **TODO**
 
####`host_ip`
Sets the Host-IP-Address value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers. If Host-IP-Address is not specified, the appliance inserts the mapped IP (MIP) address or subnet IP (SNIP) address from which the CER request (the monitoring probe) is sent.

Valid options: IP address
 
####`http_request`
Specifies the HTTP request to send to the server (for example, "HEAD /file.html").

Valid options: 
 
####`inband_security_id
: Inband-Security-Id for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.
 
  Possible values: NO_INBAND_SECURITY, TLS
 
####`interval
: Time interval between two successive probes. Must be greater than the value of Response Time-out.
 
  Default value: 5
 
  Minimum value: 1
 
  Maximum value: 20940000
 
####`ip_address
: Set of IP addresses expected in the monitoring response from the DNS server, if the record type is A or AAAA. Applicable to DNS monitors.
 
####`ip_tunnel
: Send the monitoring probe to the service through an IP tunnel. A destination IP address must be specified.
 
  Possible values: YES, NO
 
  Default value: NO
      Valid options: <yes|no|true|false|enabled|disabled|ENABLED|DISABLED|YES|NO|on|off|ON|OFF>
 
####`kcd_account
: KCD Account used by MSSQL monitor
 
####`logon_agent_service_version
: Version number of the Citrix Advanced Access Control Logon Agent. Required by the CITRIX-AAC-LAS monitor.
 
####`logon_point_name
: Name of the logon point that is configured for the Citrix Access Gateway Advanced Access Control software. Required if you want to monitor the associated login page or Logon Agent. Applicable to CITRIX-AAC-LAS and CITRIX-AAC-LOGINPAGE monitors.
 
####`lrtm
: Calculate the least response times for bound services. If this parameter is not enabled, the appliance does not learn the response times of the bound services. Also used for LRTM load balancing.
 
  Possible values: ENABLED, DISABLED
      Valid options: <yes|no|true|false|enabled|disabled|ENABLED|DISABLED|YES|NO|on|off|ON|OFF>
 
####`max_forwards
: Maximum number of hops that the SIP request used for monitoring can traverse to reach the server. Applicable only to monitors of type SIP-UDP.
 
  Default value: 1
 
  Maximum value: 255
 
####`metric_table
: Metric table to which to bind metrics.
 
####`name
: Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.
 
####`nas_id
: NAS-Identifier to send in the Access-Request packet. Applicable to monitors of type RADIUS.
 
####`nas_ip
: Network Access Server (NAS) IP address to use as the source IP address when monitoring a RADIUS server. Applicable to monitors of type RADIUS and RADIUS_ACCOUNTING.
 
####`net_profile
: Name of the network profile.
 
####`origin_host
: Origin-Host value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.
 
####`origin_realm
: Origin-Realm value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.
 
####`password
: Password that is required for logging on to the RADIUS, NNTP, FTP, FTP-EXTENDED, MYSQL, MSSQL, POP3, CITRIX-AG, CITRIX-XD-DDC, CITRIX-WI-EXTENDED, CITRIX-XNC-ECV or CITRIX-XDM server. Used in conjunction with the user name specified for the User Name parameter.
 
####`product_name
: Product-Name value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.
 
####`protocol_version
: Version of MSSQL server that is to be monitored.
 
  Possible values: 70, 2000, 2000SP1, 2005, 2008, 2008R2, 2012
 
  Default value: TDS_PROT_70
 
####`query
: Domain name to resolve as part of monitoring the DNS service (for example, example.com).
 
####`query_type
: Type of DNS record for which to send monitoring queries. Set to Address for querying A records, AAAA for querying AAAA records, and Zone for querying the SOA record.
 
  Possible values: Address, Zone, AAAA
 
####`radius_key
: Authentication key (shared secret text string) for RADIUS clients and servers to exchange. Applicable to monitors of type RADIUS and RADIUS_ACCOUNTING.
 
####`receive_string
: String expected from the server for the service to be marked as UP. Applicable to TCP-ECV, HTTP-ECV, and UDP-ECV monitors.
 
####`resp_timeout_threshold
: Response time threshold, specified as a percentage of the Response Time-out parameter. If the response to a monitor probe has not arrived when the threshold is reached, the appliance generates an SNMP trap called monRespTimeoutAboveThresh. After the response time returns to a value below the threshold, the appliance generates a monRespTimeoutBelowThresh SNMP trap. For the traps to be generated, the "MONITOR-RTO-THRESHOLD" alarm must also be enabled.
 
  Maximum value: 100
 
####`response_codes
: Response codes for which to mark the service as UP. For any other response code, the action performed depends on the monitor type. HTTP monitors and RADIUS monitors mark the service as DOWN, while HTTP-INLINE monitors perform the action indicated by the Action parameter.
 
####`response_timeout
: Amount of time for which the appliance must wait before it marks a probe as FAILED. Must be less than the value specified for the Interval parameter.
 
  Note: For UDP-ECV monitors for which a receive string is not configured, response timeout does not apply. For UDP-ECV monitors with no receive string, probe failure is indicated by an ICMP port unreachable error received from the service.
 
  Default value: 2
 
  Minimum value: 1
 
  Maximum value: 20939000
 
####`retries
: Maximum number of probes to send to establish the state of a service for which a monitoring probe failed.
 
  Default value: 3
 
  Minimum value: 1
 
  Maximum value: 127
 
####`reverse
: Mark a service as DOWN, instead of UP, when probe criteria are satisfied, and as UP instead of DOWN when probe criteria are not satisfied.
 
  Possible values: YES, NO
 
  Default value: NO
      Valid options: <yes|no|true|false|enabled|disabled|ENABLED|DISABLED|YES|NO|on|off|ON|OFF>
 
####`rtsp_request
: RTSP request to send to the server (for example, "OPTIONS *").
 
####`script_arguments
: String of arguments for the script. The string is copied verbatim into the request.
 
####`script_name
: Path and name of the script to execute. The script must be available on the NetScaler appliance, in the /nsconfig/monitors/ directory.
 
####`secondary_password
: Secondary password that users might have to provide to log on to the Access Gateway server. Applicable to CITRIX-AG monitors.
 
####`secure
: Use a secure SSL connection when monitoring a service. Applicable only to TCP based monitors. The secure option cannot be used with a CITRIX-AG monitor, because a CITRIX-AG monitor uses a secure connection by default.
 
  Possible values: YES, NO
 
  Default value: NO
      Valid options: <yes|no|true|false|enabled|disabled|ENABLED|DISABLED|YES|NO|on|off|ON|OFF>
 
####`send_string
: String to send to the service. Applicable to TCP-ECV, HTTP-ECV, and UDP-ECV monitors.
 
####`sid
: Name of the service identifier that is used to connect to the Oracle database during authentication.
 
####`sip_method
: SIP method to use for the query. Applicable only to monitors of type SIP-UDP.
 
  Possible values: OPTIONS, INVITE, REGISTER
 
####`sip_reg_uri
: SIP user to be registered. Applicable only if the monitor is of type SIP-UDP and the SIP Method parameter is set to REGISTER.
 
####`sip_uri
: SIP URI string to send to the service (for example, sip:sip.test). Applicable only to monitors of type SIP-UDP.
 
####`site_path
: URL of the logon page. For monitors of type CITRIX-WEB-INTERFACE, to monitor a dynamic page under the site path, terminate the site path with a slash (/). Applicable to CITRIX-WEB-INTERFACE, CITRIX-WI-EXTENDED and CITRIX-XDM monitors.
 
####`snmp_alert_retries
: Number of consecutive probe failures after which the appliance generates an SNMP trap called monProbeFailed.
 
  Maximum value: 32
 
####`snmp_community
: Community name for SNMP monitors.
 
####`snmp_oid
: SNMP OID for SNMP monitors.
 
####`snmp_threshold
: Threshold for SNMP monitors.
 
####`snmp_version
: SNMP version to be used for SNMP monitors.
 
  Possible values: V1, V2
 
####`sql_query
: SQL query for a MYSQL-ECV or MSSQL-ECV monitor. Sent to the database server after the server authenticates the connection.
 
####`state
: State of the monitor. The DISABLED setting disables not only the monitor being configured, but all monitors of the same type, until the parameter is set to ENABLED. If the monitor is bound to a service, the state of the monitor is not taken into account when the state of the service is determined.
  Valid options: <yes|no|true|false|enabled|disabled|ENABLED|DISABLED|YES|NO|on|off|ON|OFF>
 
####`store_db
: Store the database list populated with the responses to monitor probes. Used in database specific load balancing if MSSQL-ECV/MYSQL-ECV monitor is configured.
 
  Possible values: ENABLED, DISABLED
 
####`store_name
: Store Name. For monitors of type STOREFRONT, STORENAME is an optional argument defining storefront service store name. Applicable to STOREFRONT monitors.
 
####`storefront_account_service
: Enable/Disable probing for Account Service. Applicable only to Store Front monitors. For multi-tenancy configuration users my skip account service
 
  Possible values: YES, NO
 
  Default value: YES
 
####`success_retries
: Number of consecutive successful probes required to transition a service's state from DOWN to UP.
 
  Default value: 1
 
  Minimum value: 1
 
  Maximum value: 32
 
####`supported_vendor_ids
: List of Supported-Vendor-Id attribute value pairs (AVPs) for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers. A maximum eight of these AVPs are supported in a monitoring message.
 
  Minimum value: 1
 
  Maximum value: 4294967295
 
####`tos
: Probe the service by encoding the destination IP address in the IP TOS (6) bits.
 
  Possible values: YES, NO
      Valid options: <yes|no|true|false|enabled|disabled|ENABLED|DISABLED|YES|NO|on|off|ON|OFF>
 
####`tos_id
: The TOS ID of the specified destination IP. Applicable only when the TOS parameter is set.
 
  Minimum value: 1
 
  Maximum value: 63
 
####`transparent
: The monitor is bound to a transparent device such as a firewall or router. The state of a transparent device depends on the responsiveness of the services behind it. If a transparent device is being monitored, a destination IP address must be specified. The probe is sent to the specified IP address by using the MAC address of the transparent device.
 
  Possible values: YES, NO
 
  Default value: NO
      Valid options: <yes|no|true|false|enabled|disabled|ENABLED|DISABLED|YES|NO|on|off|ON|OFF>
 
####`type
: Type of monitor that you want to create.
 
  Possible values: PING, TCP, HTTP, TCP-ECV, HTTP-ECV, UDP-ECV, DNS, FTP, LDNS-PING, LDNS-TCP, LDNS-DNS, RADIUS, USER, HTTP-INLINE, SIP-UDP, LOAD, FTP-EXTENDED, SMTP, SNMP, NNTP, MYSQL, MYSQL-ECV, MSSQL-ECV, ORACLE-ECV, LDAP, POP3, CITRIX-XML-SERVICE, CITRIX-WEB-INTERFACE, DNS-TCP, RTSP, ARP, CITRIX-AG, CITRIX-AAC-LOGINPAGE, CITRIX-AAC-LAS, CITRIX-XD-DDC, ND6, CITRIX-WI-EXTENDED, DIAMETER, RADIUS_ACCOUNTING, STOREFRONT, APPC, CITRIX-XNC-ECV, CITRIX-XDM
 
####`####`user_name
: User name with which to probe the RADIUS, NNTP, FTP, FTP-EXTENDED, MYSQL, MSSQL, POP3, CITRIX-AG, CITRIX-XD-DDC, CITRIX-WI-EXTENDED, CITRIX-XNC or CITRIX-XDM server.
 
####`validate_credentials
: Validate the credentials of the Xen Desktop DDC server user. Applicable to monitors of type CITRIX-XD-DDC.
 
  Possible values: YES, NO
 
  Default value: NO
      Valid options: <yes|no|true|false|enabled|disabled|ENABLED|DISABLED|YES|NO|on|off|ON|OFF>
 
####`vendor_id
: Vendor-Id value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.
 
####`vendor_specific_vendor_id
: Vendor-Id to use in the Vendor-Specific-Application-Id grouped attribute-value pair (AVP) in the monitoring CER message. To specify Auth-Application-Id or Acct-Application-Id in Vendor-Specific-Application-Id, use vendorSpecificAuthApplicationIds or vendorSpecificAcctApplicationIds, respectively. Only one Vendor-Id is supported for all the Vendor-Specific-Application-Id AVPs in a CER monitoring message.
 
  Minimum value: 1

###Type: netscaler_server

Manages basic NetScaler server objects, either IP address based servers or domain-based servers.
 
####Parameters
 
####`address`
Specifies the domain name, IPv4 address, or IPv6 address of the server.

Valid options: 'ipv4', 'ipv6', or 'domain name'. 
 
####`comments`
Provides any necessary or additional information about the server.

Valid options: '< String >'
 
####`disable_wait_time`
Specifies a wait time when disabling a server object. During the wait time, the server object continues to handle established connections but rejects new connections.
 
Valid options: '/\d+/'.
 
####`ensure`
Determines whether the server object is present or absent.
 
Valid values are `present`, `absent`.
 
####`graceful_shutdown`
Enables graceful shutdown of the server, in which the system will wait for all outstanding connections to the server to be closed before disabling it.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.
 
####`ipv6_domain`
Supports IPv6 addressing mode. If you configure a server with the IPv6 addressing mode, you cannot use the server in the IPv4 addressing mode

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.
 
####`name`
Specifies the name for the server. 

Valid options: Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.
 
####`resolve_retry`
Sets the time, in seconds, the NetScaler appliance must wait after DNS resolution fails before sending the next DNS query to resolve the domain name.

Valid options: Integer; maximum = 20939 and minimum = 5. Default: 5
 
####`state`
Sets the state of the server.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.
   
####`traffic_domain_id`
Specifies the integer value that uniquely identifies the traffic domain in which you want to configure the entity. If you do not specify an ID, the entity becomes part of the default traffic domain.
 
Valid options: Integer; minimum = 0 and maximum = 4096. Default: 0
 
####`translation_ip_address`
Specifies the IP address used to transform the server's DNS-resolved IP address.

Valid options: **TODO**
 
####`translation_mask`
Sets the netmask of the translation IP. 

Valid options: **TODO**

###Type: netscaler_service

Manages service on the NetScaler appliance. If the service is domain-based, you must use the `add server`command to create the server entry before creating the service. You must specify the Server parameter**?** in the command `add server X`**TODO:?**
 
####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.
 
#####`access_down`
Determines whether to use Layer 2 mode to bridge the packets sent to the service if it is marked as DOWN. If the service is DOWN and this parameter is disabled, the packets are dropped.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: **TODO**
 
#####`appflow_logging`
Enables logging of AppFlow information.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: **TODO**
 
#####`cache_type`
Specifies the cache type supported by the cache server.

Valid options: **TODO**
 
#####`cacheable`
Uses the transparent cache redirection virtual server to forward requests to the cache server. May not be specified if `cache_type` is 'TRANSPARENT', 'REVERSE', or 'FORWARD'.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: **TODO**
 
#####`clear_text_port`
Sets the port to which clear text data must be sent after the appliance decrypts incoming SSL traffic. Applicable to transparent SSL services.

Valid options: **TODO**
 
#####`client_idle_timeout`
Specifies the time, in seconds, after which to terminate an idle client connection.
 
Valid options: integer; max = 31536000s. Default:**TODO**
 
#####`client_ip`
Determines whether to insert an HTTP header with the client's IPv4 or IPv6 address as its value before forwarding a request to the service. Use if the server needs the client's IP address for security, accounting, or other purposes, and setting the `use_source_ip` parameter is not a viable option.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: **TODO**
   
#####`client_ip_header`
Specifies the name for the HTTP header whose value must be set to the IP address of the client. Used with the `client_ip` parameter. 

If you set `client_ip` and you do not specify a name for the header, the appliance uses the header name specified for the global `client_ip_header` parameter. If the global `client_ip_header` parameter is not specified, the appliance inserts a header with the name "client-ip."

Valid options:**TODO**
 
#####`client_keepalive`
Enables client keep-alive for the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: **TODO**
   
#####`comments`
Provides any necessary or additional information about the service.

Valid options: **TODO**
 
#####`down_state_flush`
Flushes all active transactions associated with a service whose state transitions from UP to DOWN. Do not enable this option for applications that must complete their transactions.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: **TODO**
 
#####`ensure`
Determines whether the service is present or absent.
 
Valid options: 'present' or 'absent'. Default:**TODO**
 
#####`graceful_shutdown`
Enables graceful shutdown of the server, meaning the system will wait for all outstanding connections to this server to be closed before disabling it.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: "**TODO**"
 
#####`hash_id`
Specifies a numerical identifier to be used by hash-based load balancing methods. Must be unique for each service.
 
Valid options: Integer; minimum = 1. Default: **TODO**
 
#####`health_monitoring`
Monitors the health of this service. Enabling this parameter sends probes to check the health of the service. Disabling this parameter means no probes are sent to check the health of the service, and the appliance shows the service as UP at all times.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: **TODO**
 
#####`max_bandwidth`
Sets the maximum bandwidth, in Kbps, allocated to the service.
 
Valid options: Integers; maximum = 4294967287. Default: **TODO**
 
#####`max_clients`
Sets the maximum number of simultaneous open connections to the service.
 
Valid options: Integers; maximum = 4294967294. Default: **TODO**
 
#####`max_requests`
Sets the maximum number of requests that can be sent on a persistent connection to the service. Connection requests beyond this value are rejected.
 
Valid options: Integers; maximum = 65535. Default: **TODO**
 
#####`monitor_threshold`
Specifies the minimum sum of weights of the monitors that are bound to this service. Used to determine whether to mark a service as UP or DOWN.
 
Valid options: Integers; maximum = 65535. Default: **TODO**
 
#####`name`
Specifies the name for the service. 

Valid options: Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters. Default: **TODO**
 
#####`port`
*Required.* Specifies the port number of the service.

Valid options: '*' or integers.
 
#####`protocol`
*Required.* Specifies the protocol in which data is exchanged with the service.

Valid options: **TODO**

#####`server_id`
Specifies a unique identifier for the service. Used when the persistency type for the virtual server is set to 'Custom Server ID'.

Valid options: **TODO**
 
#####`server_idle_timeout`
Sets the time, in seconds, after which to terminate an idle server connection.
 
Valid options: Integers; maximum = 31536000. Default: **TODO**
 
#####`server_name`
*Required.* Specifies the name of the server that hosts the service.

Valid options:
 
#####`state`
Sets the state of the node resource.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: **TODO**
 
#####`sure_connect`
Sets the state of SureConnect for the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: **TODO**
 
#####`surge_protection`
Enables surge protection for the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: **TODO**
 
#####`tcp_buffering`
Enables TCP buffering for the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: **TODO**
 
#####`traffic_domain_id`
Specifies the integer value that uniquely identifies the traffic domain in which you want to configure the entity. If you do not specify an ID, the entity becomes part of the default traffic domain.

Valid options: Integer; minimum = 0 and maximum = 4096. Default: 0
 
#####`use_proxy_port`
Uses the proxy port as the source port when initiating connections with the server. Disabling this parameter means the client-side connection port is used as the source port for the server-side connection. This parameter is available only when the `use_source_ip` parameter is set to 'YES'. **TODO: Set to yes or simply enabled?**

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: **TODO**
 
#####`use_source_ip`
Uses the client's IP address as the source IP address when initiating a connection to the server. When creating a service, if you do not set this parameter, the service inherits the global Use Source IP setting (available in the enable ns mode and disable ns mode CLI commands, or in the System > Settings > Configure modes > Configure Modes dialog box). However, you can override this setting after you create the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

