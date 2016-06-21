#netscaler

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with netscaler](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with netscaler](#beginning-with-netscaler)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Set up two load-balanced web servers](#set-up-two-load-balanced-web-servers)
    * [Tips and tricks](#tips-and-tricks)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

##Overview

The netscaler module enables Puppet configuration of Citrix NetScaler devices through types and REST-based providers.

##Module Description

This module uses REST to manage various aspects of NetScaler load balancers, and acts
as a foundation for building higher level abstractions within Puppet.

The module allows you to manage NetScaler nodes and pool configuration through Puppet.

##Setup

###Beginning with netscaler

This module uses `puppet device` instead of `puppet agent` to manage the devices. The `puppet device` subcommand interacts with administrative interfaces to implement types and providers. This allows resources to talk to the device and translate the module into network calls.

Before you can use the netscaler module, you must create a proxy system able to run `puppet device`. In order to do so, you'll need a Puppet master and a Puppet agent as usual, and one node as the "proxy system" for `puppet device`.

This means you must create a device.conf file in the Puppet conf directory (either /etc/puppet or /etc/puppetlabs/puppet) on the Puppet agent. Within your device.conf, you must have:


~~~
[<DEVICE CERTNAME>]
  type netscaler
  url https://<USERNAME>:<PASSWORD>@<IP ADDRESS or FULLY QUALIFIED HOST NAME>/nitro/v1/
~~~

In the above example, the username and password must be for a user with superuser privileges (i.e., the NetScaler administrator). The default admin username is 'nsroot'. The certname should be the certname of the NetScaler device.

Additionally, you must install the faraday gem on the proxy host (Puppet agent). You can do this by declaring the `netscaler` class on that host. If you do not install the faraday gem, the module will not work.

##Usage

###Set up two load-balanced web servers

####Before you begin

This example is built around the following infrastructure: A server running a Puppet master is connected to the NetScaler device. The NetScaler device contains a management VLAN, a client VLAN that contains the virtual server, and a server VLAN that connects to the two web servers the module will be setting up.

In order to successfully set up your web servers, you must know the following information about your systems:

* The IP addresses of both of the web servers.
* The names of the nodes each web server will be on.
* The ports the web servers are listening on.
* The IP address of the virtual server.

####Step One: Classifying your device

In your site.pp file, enter the below code:

~~~
node 'device certname' {
  netscaler_server { 'server1':
    ensure  => present,
    address => '1.10.1.1',
  }
  netscaler_service { 'service1':
    ensure      => 'present',
    server_name => 'server1',
    port        => '80',
    protocol    => 'HTTP',
    comments    => 'This is a comment'
  }
  netscaler_lbvserver { 'lbvserver1':
    ensure       => 'present',
    service_type => 'HTTP',
    ip_address   => '1.10.1.2',
    port         => '8080',
    state        => true,
  }
  netscaler_lbvserver_service_binding { 'lbvserver1/service1':
    ensure => 'present',
    weight => '100',
  }
  netscaler_rewritepolicy { 'rewritepolicy_test1':
    ensure                  => 'present',
    action                  => 'NOREWRITE',
    comments                => 'comment',
    expression              => 'HTTP.REQ.URL.SUFFIX.EQ("")',
    undefined_result_action => 'DROP',
  }
  netscaler_csvserver { 'csvserver_test1':
    ensure        => 'present',
    service_type  => 'HTTP',
    state         => true,
    ip_address    => '2.4.1.1',
    port          => '8080',
  }
  netscaler_csvserver_rewritepolicy_binding { 'csvserver_test1/rewritepolicy_test1':
    ensure               => present,
    priority             => 1,
    invoke_vserver_label => 'csvserver_test1',
    choose_type          => 'Request',
  }
}
~~~

####Step Two: Run `puppet device`

Run the following to have the proxy node apply your classifications and configure the NetScaler device:

~~~
$ puppet device -v --user=root
~~~

If you do not run this command, clients will not be able to make requests to the web servers.

At this point, your NetScaler should be ready to handle requests for the web servers.

###Tips and tricks

####Basic usage

Once you've established a basic configuration, you can explore the providers and their allowed options by running `puppet resource <TYPENAME>` for each type. This will provide a starting point for seeing what's already on your NetScaler. If anything failed to set up properly, it will not show up when you run the command.

Call the types from the proxy system.

~~~
$ FACTER_url=https://<USERNAME>:<PASSWORD>@<NETSCALER1.EXAMPLE.COM> puppet resource netscaler_lbvserver
~~~

####Roles and profiles

The [above example](#set-up-two-load-balanced-web-servers) is a proof-of-concept for setting up a simple configuration of two web servers. We recommend using the roles and profiles pattern for anything else.

##Reference

###Public Types

* [`netscaler_csaction`](#type-netscaler_csaction)
* [`netscaler_cspolicy`](#type-netscaler_cspolicy)
* [`netscaler_cspolicylabel`](#type-netscaler_cspolicylabel)
* [`netscaler_cspolicylabel_cspolicy_binding`](#type-netscaler_cspolicylabel_cspolicy_binding)
* [`netscaler_csvserver`](#type-netscaler_csvserver)
* [`netscaler_csvserver_cspolicy_binding`](#type-netscaler_cspolicy_binding)
* [`netscaler_csvserver_responderpolicy_binding`](#type-netscaler_csvserver_responderpolicy_binding)
* [`netscaler_csvserver_rewritepolicy_binding`](#type-netscaler_csvserver_rewritepolicy_binding)
* [`netscaler_feature`](#type-netscaler_feature)
* [`netscaler_file`](#type-netscaler_file)
* [`netscaler_group_user_binding`](#type-netscaler_group_user_binding)
* [`netscaler_lbmonitor`](#type-netscaler_lbmonitor)
* [`netscaler_lbvserver`](#type-netscaler_lbvserver)
* [`netscaler_lbvserver_responderpolicy_binding`](#type-netscaler_lbvserver_responderpolicy_binding)
* [`netscaler_lbvserver_rewritepolicy_binding`](#type-netscaler_lbvserver_rewritepolicy_binding)
* [`netscaler_lbvserver_service_binding`](#type-netscaler_lbvserver_service_binding)
* [`netscaler_nshostname`](#type-netscaler_nshostname)
* [`netscaler_nsip`](#type-netscaler_nsip)
* [`netscaler_ntpserver`](#type-netscaler_ntpserver)
* [`netscaler_ntpsync`](#type-netscaler_ntpsync)
* [`netscaler_responderaction`](#type-netscaler_responderaction)
* [`netscaler_responderglobal`](#type-netscaler_responderglobal)
* [`netscaler_responderpolicy`](#type-netscaler_responderpolicy)
* [`netscaler_responderpolicylabel`](#type-netscaler_responderpolicylabel`)
* [`netscaler_rewriteaction`](#type-netscaler_rewriteaction`)
* [`netscaler_rewriteglobal`](#type-netscaler_rewriteglobal`)
* [`netscaler_rewritepolicy`](#type-netscaler_rewritepolicy`)
* [`netscaler_rewritepolicylabel`](#type-netscaler_rewritepolicylabel`)
* [`netscaler_route`](#type-netscaler_route)
* [`netscaler_server`](#type-netscaler_server)
* [`netscaler_service`](#type-netscaler_service)
* [`netscaler_servicegroup`](#type-netscaler_servicegroup)
* [`netscaler_servicegroup_lbmonitor_binding`](#type-netscaler_servicegroup_lbmonitor_binding)
* [`netscaler_servicegroup_member`](#type-netscaler_servicegroup_member)
* [`netscaler_service_lbmonitor_binding`](#type-netscaler_service_lbmonitor_binding)
* [`netscaler_snmpalarm`](#type-netscaler_snmpalarm)
* [`netscaler_sslcertfile`](#type-netscaler_sslcertfile)
* [`netscaler_sslcertkey`](#type-netscaler_sslcertkey)
* [`netscaler_sslkeyfile`](#type-netscaler_sslkeyfile)
* [`netscaler_sslocsresponder`](#type-netscaler_sslocsresponder)
* [`netscaler_sslvserver_sslcertkey_binding`](#type-netscaler_sslvserver_sslcertkey_binding)
* [`netscaler_user`](#type-netscaler_user)
* [`netscaler_vlan`](#type-netscaler_vlan)
* [`netscaler_vlan_nsip_binding`](#type-netscaler_vlan_nsip_binding)


###Type: netscaler_csaction

Manages basic NetScaler content switching action objects.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`comments`

Any information about the responder action.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`target_lb_expression`

Information about this content switching action.

#####`target_lbvserver`

Name of the load balancing virtual server to which the content is switched.

###Type: netscaler_cspolicy

Manages basic NetScaler cs policy objects.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`action`

Name of the cs action to perform if the request matches this cs policy.

#####`domain`

The domain name. The string value can range to 63 characters.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`expression`

The expression, or name of a named expression, against which traffic is evaluated. Written in the classic or default syntax.

#####`log_action`

Name of the messagelog action to use for requests that match this policy.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`url`

URL string that is matched with the URL of a request. Can contain a wildcard character. Specify the string value in the following format: 'prefix.suffix'.

###Type: netscaler_cspolicylabel

Manages basic NetScaler cs action objects.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`label_type`

Protocol supported by the policy label. All policies bound to the policy label must either match the specified protocol or be a subtype of that protocol. Available settings function as follows:

* 'HTTP' - Supports policies that process HTTP traffic. Used to access unencrypted Web sites. This is the default setting.
* 'SSL' - Supports policies that process HTTPS/SSL encrypted traffic. Used to access encrypted Web sites.
* 'TCP' - Supports policies that process any type of TCP traffic, including HTTP.
* 'SSL_TCP' - Supports policies that process SSL-encrypted TCP traffic, including SSL.
* 'UDP' - Supports policies that process any type of UDP-based traffic, including DNS.
* 'DNS' - Supports policies that process DNS traffic.
* 'ANY' - Supports all types of policies except HTTP, SSL, and TCP.
* 'SIP_UDP' - Supports policies that process UDP based Session Initiation Protocol (SIP) traffic. SIP initiates, manages, and terminates multimedia communications sessions, and has emerged as the standard for Internet telephony (VoIP).
* 'RTSP' - Supports policies that process Real Time Streaming Protocol (RTSP) traffic. RTSP provides delivery of multimedia and other streaming data, such as audio, video, and other types of streamed media.
* 'RADIUS' - Supports policies that process Remote Authentication Dial In User Service (RADIUS) traffic. RADIUS supports combined authentication, authorization, and auditing services for network management.
* 'MYSQL' - Supports policies that process MYSQL traffic.
* 'MSSQL' - Supports policies that process Microsoft SQL traffic.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

###Type: netscaler_cspolicylabel_cspolicy_binding

Manages a binding between a content switching vserver and a content switching policy.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`goto_expression`

Expression specifying the priority of the next policy that gets evaluated if the current policy rule evaluates to true.

#####`invoke_policy_label`

Label of policy to invoke if the bound policy evaluates to true.

#####`name`

The title of the bind resource, composed of the title of the cspolicylabel and the title of the cspolicy: 'cspolicylabel_name/cspolicy_name'.

#####`priority`

Specifies the priority of the policy. Values can be any integer between 1 and 2147483647.

Min = 1
Max = 2147483647

#####`target_lbvserver`

The virtual server name to which content will be switched.

###Type: netscaler_csvserver

Manages content switching vserver on the NetScaler appliance.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`appflow_logging`

Enable logging appflow flow information.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`authentication`

This option toggles on or off the application of authentication of incoming users to the vserver.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`authentication_401`

This option toggles on or off the HTTP 401 response based authentication.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`authentication_fqdn`

Fully qualified domain name (FQDN) of the authentication virtual server to which the user must be redirected for authentication. Make sure that the Authentication parameter is set to ENABLED.

#####`authentication_profile_name`

The name of the authentication profile to be used when authentication is turned on.

#####`authentication_virtual_server_name`

Name of an authentication virtual server with which to authenticate users.

#####`backup_virtual_server`

Name of the backup virtual server to which to forward requests if the primary virtual server goes DOWN or reaches its spillover threshold.

#####`cacheable`

The option to specify whether a virtual server used for content switching will route requests to the cache redirection virtual server before sending it to the configured servers.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`case_sensitive`

The URL lookup case option on the content switching vserver.

If case sensitivity of a content switching virtual server is set to 'ON', the URLs /a/1.html and /A/1.HTML are treated differently and can have different targets (set by content switching policies).

If case sensitivity is set to 'OFF', the URLs /a/1.html and /A/1.HTML are treated the same and are switched to the same target.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`client_timeout`

Client timeout in seconds.

Maximum value: 31536000.

#####`comment`

Any comments you want to associate with this virtual server.

#####`db_profile_name`

Name of the DB profile whose settings are to be applied to the virtual server.

#####`default_lbvserver`

The virtual server name to which content will be switched.

#####`disable_primary_on_down`

When this argument is enabled, traffic will continue reaching backup vservers even after primary comes UP from DOWN state.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`down_state_flush`

Perform delayed clean up of connections on this vserver.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`http_profile_name`

Name of the HTTP profile whose settings are to be applied to the virtual server.

#####`icmp_virtual_server_response`

How the NetScaler appliance responds to ping requests received for an IP address that is common to one or more virtual servers. Available settings function as follows:

* If set to PASSIVE on all the virtual servers that share the IP address, the appliance always responds to the ping requests.
* If set to ACTIVE on all the virtual servers that share the IP address, the appliance responds to the ping requests if at least one of the virtual servers is UP. Otherwise, the appliance does not respond.
* If set to ACTIVE on some virtual servers and PASSIVE on the others, the appliance responds if at least one virtual server with the ACTIVE setting is UP. Otherwise, the appliance does not respond.

Note: This parameter is available at the virtual server level. A similar parameter, ICMP Response, is available at the IP address level, for IPv4 addresses of type VIP. To set that parameter, use the add ip command in the CLI or the Create IP dialog box in the GUI.

#####`ip_address`

Specifies the set of IP addresses expected in the monitoring response from the DNS server if the record type is A or AAAA. Applicable to DNS monitors.

Valid options: An IP address or an array of IP addresses.

#####`ip_mask`

IP mask, in dotted decimal notation, for the IP Pattern parameter. Can have leading or trailing non-zero octets (for example, 255.255.240.0 or 0.0.255.255). Accordingly, the mask specifies whether the first n bits or the last n bits of the destination IP address in a client request are to be matched with the corresponding bits in the IP pattern. The former is called a forward mask. The latter is called a reverse mask.

#####`ip_pattern`

IP address pattern, in dotted decimal notation, for identifying packets to be accepted by the virtual server. The IP Mask parameter specifies which part of the destination IP address is matched against the pattern.  Mutually exclusive with the IP Address parameter.

For example, if the IP pattern assigned to the virtual server is 198.51.100.0 and the IP mask is 255.255.240.0 (a forward mask), the first 20 bits in the destination IP addresses are matched with the first 20 bits in the pattern. The virtual server accepts requests with IP addresses that range from 198.51.96.1 to 198.51.111.254.  You can also use a pattern such as 0.0.2.2 and a mask such as 0.0.255.255 (a reverse mask).

If a destination IP address matches more than one IP pattern, the pattern with the longest match is selected, and the associated virtual server processes the request. For example, if virtual servers vs1 and vs2 have the same IP pattern, 0.0.100.128, but different IP masks of 0.0.255.255 and 0.0.224.255, a destination IP address of 198.51.100.128 has the longest match with the IP pattern of vs1. If a destination IP address matches two or more virtual servers to the same extent, the request is processed by the virtual server

#####`layer2_parameters`

Identifies a connection.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`listen_policy`

Specifies the listen policy for csvserver. The string can be either an existing expression name (configured using add policy expression command) or else it can be an in-line expression with a maximum of 1499 characters.

#####`listen_priority`

Specifies the priority for listen policy of csvserver.

Maximum value: 100

#####`mssql_server_version`

The version of the MSSQL server.

Valid options: 70, 2000, 2000SP1, 2005, 2008, 2008R2.

#####`mysql_character_set`

The character set returned by the MySQL vserver.

#####`mysql_protocol_version`

The protocol version returned by the MySQL vserver.

#####`mysql_server_capabilities`

The server capabilities returned by the MySQL vserver.

#####`mysql_server_version`

The server version string returned by the MySQL vserver.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`net_profile_name`

The name of the network profile.

#####`oracle_server_version`

Oracle server version.

Valid options: 10G, 11G.

#####`port`

*Required.* Specifies the port number of the service.

Valid options: '*' or integers. Minimum value: 1.

#####`precedence`

The precedence on the content switching virtual server between rule-based and URL-based policies.

Valid options: RULE, URL. The default precedence is RULE.

* RULE: If the precedence is configured as RULE, the incoming request is applied against the content switching policies created with the -rule argument. If none of the rules match, then the URL in the request is applied against the content switching policies created with the -url option.

  For example, this precedence can be used if certain client attributes (such as a specific type of browser) need to be served different content and all other clients can be served from the content distributed among the servers.

* URL: If the precedence is configured as URL, the incoming request URL is applied against the content switching policies created with the -url option. If none of the policies match, then the request is applied against the content switching policies created with the -rule option.

  This precedence can also be used if some content (such as images) is the same for all clients, but other content (such as text) is different for different clients. In this case, the images will be served to all clients, but the text will be served to specific clients based on specific attributes, such as Accept-Language.


#####`purge_bindings`

When true, Puppet will purge all unmanaged `netscaler_csvserver_rewritepolicy_binding` and `netscaler_csvserver_responderpolicy_binding` resources associated with this csvserver. Valid options: 'true', 'false'. Default: 'false'.

#####`push`

Processes traffic on bound Push vserver.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`push_label_expression`

Specifies the expression to extract the label in response from server. The string can be either a named expression (configured using add policy expression command) or else it can be an in-line expression with a maximum of 63 characters.

#####`push_multiple_clients`

Specifies if multiple web 2.0 connections from the same client can connect to this vserver and expect updates.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`push_virtual_server_name`

Name of the type PUSH/SSL_PUSH lbvserver to which the server pushes updates received on the client-facing load balancing virtual server.

#####`range`

Number of IP addresses that the appliance must generate and assign to the virtual server. The virtual server then functions as a network virtual server, accepting traffic on any of the generated IP addresses. The IP addresses are generated automatically, as follows:

* For a range of n, the last octet of the address specified by the IP Address parameter increments n-1 times.
* If the last octet exceeds 255, it rolls over to 0 and the third octet increments by 1.

Minimum value: 1
Maximum value: 254

#####`redirect_port_rewrite`

Rewrite the port and change the protocol to ensure successful HTTP redirects from services.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`redirect_url`
URL to which to redirect traffic if the virtual server becomes unavailable.

**WARNING:** Make sure that the domain in the URL does not match the domain specified for a content switching policy. If it does, requests are continuously redirected to the unavailable virtual server.

#####`rhi_state`

Injects a host route according to the setting on the virtual servers.

Valid options: PASSIVE, ACTIVE.

* If set to PASSIVE on all the virtual servers that share the IP address, the appliance always injects the hostroute.
* If set to ACTIVE on all the virtual servers that share the IP address, the appliance injects even if one virtual server is UP.
* If set to ACTIVE on some virtual servers and PASSIVE on the others, the appliance, injects even if one virtual server set to ACTIVE is UP.

#####`rtsp_natting`

Enables natting for RTSP data connection.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`service_type`

Specifies the service type of the virtual server.

Valid options: HTTP, SSL, TCP, FTP, RTSP, SSL_TCP, UDP, DNS, SIP_UDP, ANY, RADIUS, RDP, MYSQL, MSSQL, DIAMETER, SSL_DIAMETER.

#####`spillover_backup_action`

Specifies the action to be performed if spillover is to take effect, but no backup chain to spillover is usable or exists.

Valid options: DROP, ACCEPT, REDIRECT.

#####`spillover_method`

Specifies the type of threshold that, when exceeded, triggers spillover. Available settings function as follows:

* 'CONNECTION' - Spillover occurs when the number of client connections exceeds the threshold.
* 'DYNAMICCONNECTION' - Spillover occurs when the number of client connections at the virtual server exceeds the sum of the maximum client (Max Clients) settings for bound services. Do not specify a spillover threshold for this setting, because the threshold is implied by the Max Clients settings of bound services.
* 'BANDWIDTH' - Spillover occurs when the bandwidth consumed by the virtual server's incoming and outgoing traffic exceeds the threshold.
* 'HEALTH' - Spillover occurs when the percentage of weights of the services that are UP drops below the threshold. For example, if services svc1, svc2, and svc3 are bound to a virtual server, with weights 1, 2, and 3, and the spillover threshold is 50%, spillover occurs if svc1 and svc3 or svc2 and svc3 transition to DOWN.
* 'NONE' - Spillover does not occur.

#####`spillover_persistence`

If spillover occurs, maintain source IP address based persistence for both primary and backup virtual servers.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`spillover_persistence_timeout`

Timeout for spillover persistence, in minutes.

Minimum value: 2
Maximum value: 1440

#####`spillover_threshold`

If the spillover method is set to CONNECTION or DYNAMICCONNECTION, this value is treated as the maximum number of connections a virtual server will handle before spillover takes place. If the spillover method is set to BANDWIDTH, this value is treated as the amount of incoming and outgoing traffic (in Kbps) a vserver will handle before spillover takes place.

Minimum value: 1
Maximum value: 4294967287

#####`state`

The initial state, enabled or disabled, of the virtual server.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`state_update`

To enable the state update for a CSW vserver.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`tcp_profile_name`

Name of the TCP profile whose settings are to be applied to the virtual server.

#####`traffic_domain`

An integer value that uniquely identifies the traffic domain in which you want to configure the entity. If you do not specify an ID, the entity becomes part of the default traffic domain, which has an ID of 0.

Minimum value = 0
Maximum value = 4094

#####`vip_header_name`

Name of virtual server IP and port header, for use with the VServer IP Port Insertion parameter.

#####`virtual_server_ip_port_insertion`

The virtual IP and port header insertion option for the vserver. Accepts the following values:

* 'VIPADDR' - Header contains the vserver's IP address and port number without any translation.
* 'OFF' - The virtual IP and port header insertion option is disabled.
* 'V6TOV4MAPPING' - Header contains the mapped IPv4 address that corresponds to the IPv6 address of the vserver and the port number. An IPv6 address can be mapped to a user-specified IPv4 address using the set ns ip6 command.

###Type: netscaler_csvserver_cspolicy_binding

Manages a binding between a content switching vserver and a content switching policy.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`goto_expression`

Expression specifying the priority of the next policy that gets evaluated if the current policy rule evaluates to true.

#####`label_name`

Label of policy to invoke if the bound policy evaluates to true.

#####`name`

The title of the bind resource, composed of the title of the csvserver and the title of the policy: 'csvserver_name/policy_name'.

#####`priority`

The priority of the policy binding. Values can be any integer between 1 and 2147483647.

#####`target_lbvserver`

The virtual server name to which content will be switched.

###Type: netscaler_csvserver_responderpolicy_binding

Manages a binding between a content switching vserver and a responder policy.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`goto_expression`

Expression specifying the priority of the next policy that gets evaluated if the current policy rule evaluates to true.

#####`invoke_policy_label`

Label of policy to invoke if the bound policy evaluates to true.

#####`invoke_vserver_label`

Label of vserver to invoke if the bound policy evaluates to true.

#####`name`

The title of the bind resource, composed of the title of the csvserver and the title of the responder policy: 'csvserver_name/policy_name'.

#####`priority`

The priority of the policy binding. Values can be any integer between 1 and 2147483647.

###Type: netscaler_csvserver_rewritepolicy_binding

Manages a binding between a content switching vserver and a rewrite policy.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`choose_type`

Type of invocation when invoking a vserver. Available settings functions are Request and Response. This property is not applicable for use in conjunction with invoking a Policy Label.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`goto_expression`

Expression specifying the priority of the next policy that gets evaluated if the current policy rule evaluates to true.

#####`invoke_policy_label`

Label of policy to invoke if the bound policy evaluates to true.

#####`invoke_vserver_label`

Label of csvserver to invoke if the bound policy evaluates to true.

#####`name`

The title of the bind resource, composed of the title of the csvserver and the title of the rewrite policy: 'csvserver_name/policy_name'.

#####`priority`

The priority of the policy binding. Values can be any integer between 1 and 2147483647.

###Type: netscaler_feature

Enables or disables licensed features on a NetScaler device. Licensed features must be enabled before they can be used. For example, the Content Switching feature must be enabled before the content switching resources can be used.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`name`

Name for the feature. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

###Type: netscaler_file

Allows the uploading of a file to the NetScaler. Only accepts names of *.cert *.key and *.txt.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`content`

The file content. This content will be encoded to Base64.

#####`encoding`

Encoding type of the file content. Only accepts 'BASE64'.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`name`

The name for the file. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.


###Type: netscaler_group_user_binding

The group and user binding, in the following format:

`group/user:gateway eg testers/joe`

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

###Type: netscaler_lbmonitor

Manages load balancer monitoring on the NetScaler appliance. If the service is domain-based, you must use the `add server` command to create the 'server' entry before you create the service. Then specify the `server` parameter in the `add server` command.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`account_application_ids`

Specifies a list of Acct-Application-Id attribute value pairs (AVPs) for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers. A maximum of eight of AVPs are supported in a monitoring message.

Valid options: An AVP or an array of up to 8 AVPs.

#####`account_session_id`

Specifies the Account Session ID to be used in Account Request Packet. Applicable to RADIUS_ACCOUNTING monitors.

Valid options: a string.

#####`account_type`

Sets the Account Type to be used in Account Request Packet. Applicable to RADIUS_ACCOUNTING monitors.

Valid options: an integer; maximum = 15 Default: 1.

#####`action`

Specifies the action to perform when the response to an inline monitor (HTTP-INLINE) indicates that the service is down. A service monitored by an inline monitor is considered DOWN if the response code is not one of the codes that have been specified for the Response Code parameter.

Valid options: 'NONE', 'LOG', or 'DOWN'. Default: 'SM_DOWN'.


The following options will have the following impact:

* 'NONE' - Takes no action.
* 'LOG' - Logs the event in NSLOG or SYSLOG.
* 'DOWN' - Marks the service as being down and ensures no traffic is directed to the service until the configured down time has expired. Persistent connections to the service are terminated as soon as the service is marked as DOWN. The event is logged in NSLOG or SYSLOG.

#####`application_name`

Sets the name of the application used to determine the state of the service. Applicable to CITRIX-XML-SERVICE monitors.

Valid options: a string.

#####`attribute`

Specifies the attribute to evaluate when the LDAP server responds to the query. Success or failure of the monitoring probe depends on whether the attribute exists in the response.

Valid options: a string.

#####`authentication_application_ids`

Specifies the list of Auth-Application-Id attribute value pairs (AVPs) for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers. A maximum of eight of these AVPs are supported in a monitoring CER message.

Valid options: An AVP or an array of up to 8 AVPs.

#####`base_dn`

Sets the base distinguished name of the LDAP service, from where the LDAP server can begin the search for the attributes in the monitoring query. Required for LDAP service monitoring.

Valid options: a string.

#####`bind_dn`

Sets the distinguished name with which an LDAP monitor can perform the Bind operation on the LDAP server. Applicable to LDAP monitors.

Valid options: a string.

#####`called_station_id`

Sets the Called Station Id to be used in Account Request Packet. Applicable to RADIUS_ACCOUNTING monitors.

Valid options: a string.

#####`calling_station_id`

Sets the Calling Stations Id to be used in Account Request Packet. Applicable to RADIUS_ACCOUNTING monitors.

Valid options: a string.

#####`check_backend_services`

Enables monitoring of services running on storefront server. Storefront services are monitored by probing to a Windows service that runs on the Storefront server and exposes details of which storefront services are running.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`custom_header`

Specifies a custom header string to include in the monitoring probes.

Valid options: a string.

#####`database`

Specifies the name of the database to connect to during authentication.

Valid options: a string.

#####`destination_ip`

Sets the IP address of the service to send probes to. If the parameter is set to 0, the IP address of the server to which the monitor is bound is considered the destination IP address.

Valid options: IP address or '0'.

#####`destination_port`

Specifies the TCP or UDP port to send the probe to. For most monitors, if the parameter is set to 0, the port number of the service to which the monitor is bound is considered the destination port. For a USER monitor, the destination port is the port number that is included in the HTTP request sent to the dispatcher. This parameter does not apply to PING monitors.

Valid options: integers.

#####`deviation`

Sets the time to add to the learned average response time in dynamic response time monitoring (DRTM). When a deviation is specified, your NetScaler appliance learns the average response time of bound services and adds the deviation to the average. The final value is then continually adjusted to accommodate response time variations over time. Specified in seconds.

Valid options: an integer expressed in seconds; maximum = 20939000 seconds.

#####`dispatcher_ip`

Sets the IP address of the dispatcher to send the probe to.

Valid options: IP address.

#####`dispatcher_port`

Sets the port number on which the dispatcher listens for the monitoring probe.

Valid options: integers.

#####`domain`

Sets the domain in which the XenDesktop Desktop Delivery Controller (DDC) servers or Web Interface servers are present. Required by CITRIX-XD-DDC and CITRIX-WI-EXTENDED monitors for logging on to the DDC servers and Web Interface servers.

Valid options: a string.

#####`down_time`

Sets the time duration to wait before probing a service that has been marked as DOWN. Expressed in seconds.

Valid option: an integer expressed in seconds; minimum = 1 second and maximum = 20939000 seconds. Default: 30 seconds.

#####`ensure`

Determines whether the load balancer monitoring service is present or absent.

Valid options: 'present' or 'absent'.

#####`expression`

Sets the default syntax expression that evaluates the database server's response to a MySQL-ECV or MSSQL-ECV monitoring query. Must produce a Boolean result, as the result determines the state of the server. If the expression returns true, the probe succeeds.

For example, if you want the appliance to evaluate the error message to determine the state of the server, use the rule 'MYSQL.RES.ROW(10) .TEXT_ELEM(2).EQ("MySQL")'.

Valid options: a string.

#####`failure_retries`

Sets the number of retries that must fail, out of the number specified for the `retries` parameter, for a service to be marked as DOWN. '0' means that all the retries must fail if the service is to be marked as DOWN.

For example, if the `retries` parameter is set to 10 and the `failure_retries` parameter is set to 6, out of the ten probes sent, at least six probes must fail if the service is to be marked as DOWN.

Valid options: an integer; maximum = 32. Default: 0.

#####`file_name`

Sets the name of a file on the FTP server. Your NetScaler appliance monitors the FTP service by periodically checking the existence of the file on the server. Applicable to FTP-EXTENDED monitors.

Valid options: a string.

#####`filter`

Filters criteria for the LDAP query.

Valid options: a string.

#####`firmware_revision`

Sets the Firmware-Revision value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.

Valid options: an integer.

#####`framed_ip`

Sets the source IP the packet will go out with. Applicable to RADIUS_ACCOUNTING monitors.

Valid options: a valid IP address.

#####`group_name`

Sets the name of a newsgroup available on the monitored NNTP service. Your NetScaler appliance periodically generates an NNTP query for the name of the newsgroup and evaluates the response. If the newsgroup is found on the server, the service is marked as UP. If the newsgroup does not exist or if the search fails, the service is marked as DOWN. Applicable to NNTP monitors.

Valid options: a string.

#####`host_ip`

Sets the Host-IP-Address value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers. If Host-IP-Address is not specified, the appliance inserts the mapped IP (MIP) address or subnet IP (SNIP) address from which the CER request (the monitoring probe) is sent.

Valid options: a valid IP address.

#####`http_request`

Specifies the HTTP request to send to the server (for example, "HEAD /file.html").

Valid options: a string.

#####`inband_security_id`

Specifies the Inband-Security-Id for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.

Valid options: 'NO_INBAND_SECURITY' or 'TLS'.

#####`interval`

Determines the time interval in seconds between two successive probes. Must be greater than the value of [`response_timeout`](#response_timeout).

Valid options: an integer expressed in seconds; minimum = 1 second and maximum = 20940000 seconds. Default: 5 seconds.

#####`ip_address`

Specifies the set of IP addresses expected in the monitoring response from the DNS server if the record type is A or AAAA. Applicable to DNS monitors.

Valid options: An array of IP addresses.

#####`ip_tunnel`

Determines whether to send the monitoring probe to the load balancing service through an IP tunnel. A destination IP address must be specified.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: 'NO'.

#####`kcd_account`

Specifices the KCD Account used by MSSQL monitor.

Valid options: a string.

#####`logon_agent_service_version`

Sets the version number of the Citrix Advanced Access Control Logon Agent. Required by the CITRIX-AAC-LAS monitor.

Valid options: a string.

#####`logon_point_name`

Specifies the name of the logon point that is configured for the Citrix Access Gateway Advanced Access Control software. Required if you want to monitor the associated login page or Logon Agent. Applicable to CITRIX-AAC-LAS and CITRIX-AAC-LOGINPAGE monitors.

Valid options: a string.

#####`lrtm`

Calculates the least response times for bound services. If this parameter is not enabled, the appliance does not learn the response times of the bound services. Also used for LRTM load balancing.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'

#####`max_forwards`

Sets the maximum number of hops that the SIP request used for monitoring can traverse to reach the server. Applicable only to SIP-UDP monitors.

Valid options: an integer; maximum = 255 Default: 1.

#####`metric_table`

Specifies a metric table to bind metrics to.

Valid options: a string.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`nas_id`

Specifies the NAS-Identifier to send in the Access-Request packet. Applicable to RADIUS monitors.

Valid options: a string.

#####`nas_ip`

Sets the Network Access Server (NAS) IP address to use as the source IP address when monitoring a RADIUS server. Applicable to  RADIUS and RADIUS_ACCOUNTING monitors.

Valid options: IP Address.

#####`net_profile`

Sets the name of the network profile.

Valid options: a string.

#####`origin_host`

Specifies the Origin-Host value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.

Valid options: a string.

#####`origin_realm`

Specifies the Origin-Realm value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.

Valid options: a string.

#####`password`

Sets the password required for logging on to the RADIUS, NNTP, FTP, FTP-EXTENDED, MYSQL, MSSQL, POP3, CITRIX-AG, CITRIX-XD-DDC, CITRIX-WI-EXTENDED, CITRIX-XNC-ECV or CITRIX-XDM servers. Used in conjunction with the user name specified for the [`user_name`](#user_name) parameter.

Valid options: a string.

#####`product_name`

Specifies the Product-Name value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.

Valid options: a string.

#####`protocol_version`

Specifies the version of MSSQL server to be monitored.

Valid options: '70', '2000', '2000SP1', '2005', '2008', '2008R2', '2012'. Default: '70'.

#####`query`

Specifies the domain name to resolve as part of monitoring the DNS service (for example, example.com).

Valid options: a string.

#####`query_type`

Sets the type of DNS record to send monitoring queries to. Set to 'Address' for querying A records, 'AAAA' for querying AAAA records, and 'Zone' for querying the SOA record.

Valid options: 'Address', 'Zone', or 'AAAA'.

#####`radius_key`

Specifies the authentication key (shared secret text string) for RADIUS clients and servers to exchange. Applicable to RADIUS and RADIUS_ACCOUNTING monitors.

Valid options: a string.

#####`receive_string`

Specifies the string expected from the server for the service to be marked as UP. Applicable to TCP-ECV, HTTP-ECV, and UDP-ECV monitors.

Valid options: a string.

#####`resp_timeout_threshold`

Sets the response time threshold, specified as a percentage of the [`response_timeout`](#response_timeout) parameter. If the response to a monitor probe has not arrived when the threshold is reached, the NetScaler appliance generates an SNMP trap called monRespTimeoutAboveThresh. After the response time returns to a value below the threshold, the appliance generates a monRespTimeoutBelowThresh SNMP trap. For the traps to be generated, the "MONITOR-RTO-THRESHOLD" alarm must also be enabled.

Valid options: an integer; maximum = 100. Default: 1.

#####`response_codes`

Sets the response codes that mark the service as UP. For any other response code, the action performed depends on the monitor type. HTTP monitors and RADIUS monitors mark the service as DOWN, while HTTP-INLINE monitors perform the action indicated by the [`action`](#action) parameter.

Valid options: a string or an array of strings.

#####`response_timeout`

Sets the amount of time the appliance must wait before it marks a probe as FAILED. Must be less than the value specified for the [`interval`](interval) parameter.

Valid options: an integer; minimum = 1s and maximum = 20939000s. Default: 2s.

Note: This parameter does not apply to UDP-ECV monitors that do not have a receive string configured. For UDP-ECV monitors with no receive string, probe failure is indicated by an ICMP port unreachable error received from the service.


#####`retries`

Sets the maximum number of probes to send to establish the state of a service for which a monitoring probe failed.

Valid options: an integer; minimum = 1 and maximum = 127. Default: 3.

#####`reverse`

Specifies whether to ,ark a service as DOWN instead of UP when probe criteria are satisfied, and as UP instead of DOWN when probe criteria are not satisfied.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: 'NO'.

#####`rtsp_request`

Specifies the RTSP request to send to the server (for example, "OPTIONS *").

Valid options: a string.

#####`script_arguments`

Specifies the string of arguments for the script. The string is copied verbatim into the request.

Valid options: a string.

#####`script_name`

Sets the path and name of the script to execute. The script must be available on the NetScaler appliance, in the /nsconfig/monitors/ directory.

Valid options: a string.

#####`secondary_password`

Sets the secondary password that users might have to provide to log on to the Access Gateway server. Applicable to CITRIX-AG monitors.

Valid options: a string.

#####`secure`

Determines whether to use a secure SSL connection when monitoring a service. Applicable only to TCP-based monitors. The secure option cannot be used with a CITRIX-AG monitor, because a CITRIX-AG monitor uses a secure connection by default.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.Default: 'NO'.

#####`send_string`

Specifies the string to send to the service. Applicable to TCP-ECV, HTTP-ECV, and UDP-ECV monitors.

Valid options: a string.

#####`sid`

Sets the name of the service identifier used to connect to the Oracle database during authentication.

Valid options: a string.

#####`sip_method`

Specifies the SIP method to use for the query. Applicable only to SIP-UDP monitors.

Valid options: 'OPTIONS', 'INVITE', or 'REGISTER'.

#####`sip_reg_uri`

Specifies the SIP user to be registered. Applicable only to SIP-UDP monitors with the  `sip_method` parameter set to 'REGISTER'.

Valid options: a string.

#####`sip_uri`

Specifies the SIP URI string to send to the service (for example, sip:sip.test). Applicable only to SIP-UDP monitors.

Valid options: a string.

#####`site_path`

Sets the URL of the logon page. For CITRIX-WEB-INTERFACE monitors: to monitor a dynamic page under the site path, terminate the site path with a slash (/). Applicable to CITRIX-WEB-INTERFACE, CITRIX-WI-EXTENDED and CITRIX-XDM monitors.

Valid options: a string.

#####`snmp_alert_retries`

Sets the number of consecutive probe failures after which the appliance generates an SNMP trap called monProbeFailed.

Valid options: an integer; maximum = 32.

#####`snmp_community`

Sets the community name for SNMP monitors.

Valid options: a string.

#####`snmp_oid`

Sets the SNMP OID for SNMP monitors.

Valid options: a string.

#####`snmp_threshold`

Specifies the threshold for SNMP monitors.

Valid options: a string.

#####`snmp_version`

Sets the SNMP version to be used for SNMP monitors.

Valid options: 'V1' or 'V2'.

#####`sql_query`

Specifies a SQL query for a MySQL-ECV or MSSQL-ECV monitor. Sent to the database server after the server authenticates the connection.

Valid options: a string.

#####`state`

Sets the state of the monitor. The 'DISABLED' setting disables not only the monitor being configured, but all monitors of the same type until the parameter is set to ENABLED. If the monitor is bound to a service, the state of the monitor is not taken into account when the state of the service is determined.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`store_db`

Determines whether to store the database list populated with the responses to monitor probes. Used in database specific load balancing if MSSQL-ECV/MySQL-ECV monitor is configured.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`store_name`

Sets the store name. Applicable to STOREFRONT monitors.

Valid options: a string.

#####`storefront_account_service`

Determines whether to enable or disable probing for Account Service. Applicable only to Store Front monitors. Multi-tenancy configuration users may skip this parameter.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: 'YES'.

#####`success_retries`

Specifies the number of consecutive successful probes required to transition a service's state from DOWN to UP.

Valid option: an integer; minimum = 1 and maximum = 32. Default: 1.

#####`supported_vendor_ids`

Lists the Supported-Vendor-Id attribute value pairs (AVPs) for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers. A maximum eight of these AVPs are supported in a monitoring message.

Valid options: An AVP or an array of up to 8 AVPs.

#####`tos`

Determines whether to probe the service by encoding the destination IP address in the IP TOS (6) bits.

Valid options:'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`tos_id`

Sets the TOS ID of the specified destination IP. Applicable only when the `tos` parameter is set.

Valid options: an integer; minimum = 1 and maximum = 63.

#####`transparent`

Determines whether the monitor is bound to a transparent device, such as a firewall or router. The state of a transparent device depends on the responsiveness of the services behind it. If a transparent device is being monitored, a destination IP address must be specified. The probe is sent to the specified IP address by using the MAC address of the transparent device.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: 'NO'.

#####`type`

Specifies type of monitor that you want to create.

Valid options: 'PING', 'TCP', 'HTTP', 'TCP-ECV', 'HTTP-ECV', 'UDP-ECV', 'DNS', 'FTP', 'LDNS-PING', 'LDNS-TCP', 'LDNS-DNS', 'RADIUS', 'USER', 'HTTP-INLINE', 'SIP-UDP', 'LOAD', 'FTP-EXTENDED', 'SMTP', 'SNMP', 'NNTP', 'MYSQL', 'MYSQL-ECV', 'MSSQL-ECV', 'ORACLE-ECV', 'LDAP', 'POP3', 'CITRIX-XML-SERVICE', 'CITRIX-WEB-INTERFACE', 'DNS-TCP', 'RTSP', 'ARP', 'CITRIX-AG', 'CITRIX-AAC-LOGINPAGE', 'CITRIX-AAC-LAS', 'CITRIX-XD-DDC', 'ND6', 'CITRIX-WI-EXTENDED', 'DIAMETER', 'RADIUS_ACCOUNTING', 'STOREFRONT', 'APPC', 'CITRIX-XNC-ECV', or 'CITRIX-XDM'.

#####`user_name`

Specifies the user name with which to probe the RADIUS, NNTP, FTP, FTP-EXTENDED, MYSQL, MSSQL, POP3, CITRIX-AG, CITRIX-XD-DDC, CITRIX-WI-EXTENDED, CITRIX-XNC or CITRIX-XDM server.

Valid options: a string.

#####`validate_credentials`

Determines whether to validate the credentials of the Xen Desktop DDC server user. Applicable to CITRIX-XD-DDC monitors.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: 'NO'.

#####`vendor_id`

Sets the vendor-ID value for the Capabilities-Exchange-Request (CER) message to use for monitoring Diameter servers.

Valid options: integers.

#####`vendor_specific_vendor_id`

Sets the vendor-ID to use in the Vendor-Specific-Application-Id grouped attribute-value pair (AVP) in the monitoring CER message. To specify Auth-Application-Id or Acct-Application-Id in Vendor-Specific-Application-Id, use vendorSpecificAuthApplicationIds or vendorSpecificAcctApplicationIds, respectively. Only one Vendor-Id is supported for all the Vendor-Specific-Application-Id AVPs in a CER monitoring message.

Valid options: integers; minimum = 1

###Type: netscaler_lbvserver

Manages load-balanced VServer on the NetScaler appliance.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`appflow_logging`

Apply AppFlow logging to the virtual server.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', DISABLED', YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`authentication`

Enable or disable user authentication. Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`authentication_401`

Enable or disable user authentication with HTTP 401 responses.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

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

If this option is enabled while resolving DNS64 query AAAA queries are not sent to back end dns server.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`cacheable`

Route cacheable requests to a cache redirection virtual server. The load balancing virtual server can forward requests only to a transparent cache redirection virtual server that has an IP address and port combination of *:80, so such a cache redirection virtual server must be configured on the appliance.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`client_timeout`

Idle time, in seconds, after which a client connection is terminated.

Valid values: an integer. Maximum value: 31536000.

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

Enable database specific load balancing for MySQL and MSSQL service types.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`db_profile_name`

Name of the DB profile whose settings are to be applied to the virtual server.

#####`disable_primary_on_down`

If the primary virtual server goes down, do not allow it to return to primary status until manually enabled.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`dns64`

This argument is for enabling/disabling the dns64 on lbvserver.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.


#####`down_state_flush`

Flush all active transactions associated with a virtual server whose state transitions from UP to DOWN. Do not enable this option for applications that must complete their transactions.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`ensure`

The basic state that the resource should be in. Valid values are 'present', 'absent'.

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

Use Layer 2 parameters (channel number, MAC address, and VLAN ID) in addition to the 4-tuple `<source IP>:<source port>::<destination IP>:<destination port>` that is used to identify a connection. Allows multiple TCP and non-TCP connections with the same 4-tuple to co-exist on the NetScaler appliance.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`lb_method`

Load balancing method. The available settings function as follows:

* 'ROUNDROBIN' - Distribute requests in rotation, regardless of the load. Weights can be assigned to services to enforce weighted round robin distribution.
* 'LEASTCONNECTION' (default) - Select the service with the fewest connections.
* 'LEASTRESPONSETIME' - Select the service with the lowest average response time.
* 'LEASTBANDWIDTH' - Select the service currently handling the least traffic.
* 'LEASTPACKETS' - Select the service currently serving the lowest number of packets per second.
* 'CUSTOMLOAD' - Base service selection on the SNMP metrics obtained by custom load monitors.
* 'LRTM' - Select the service with the lowest response time. Response times are learned through monitoring probes. This method also takes the number of active connections into account.

Also available are a number of hashing methods, in which the appliance extracts a predetermined portion of the request, creates a hash of the portion, and then checks whether any previous requests had the same hash value. If it finds a match, it forwards the request to the service that served those previous requests. The available hashing methods are as follows:

* 'URLHASH' - Create a hash of the request URL (or part of the URL).
* 'DOMAINHASH' - Create a hash of the domain name in the request (or part of the domain name). The domain name is taken from either the URL or the Host header. If the domain name appears in both locations, the URL is preferred. If the request does not contain a domain name, the load balancing method defaults to LEASTCONNECTION.
* 'DESTINATIONIPHASH' - Create a hash of the destination IP address in the IP header.
* 'SOURCEIPHASH' - Create a hash of the source IP address in the IP header.
* 'TOKEN' - Extract a token from the request, create a hash of the token, and then select the service to which any previous requests with the same token hash value were sent.
* 'SRCIPDESTIPHASH' - Create a hash of the string obtained by concatenating the source IP address and destination IP address in the IP header.
* 'SRCIPSRCPORTHASH' - Create a hash of the source IP address and source port in the IP header.
* 'CALLIDHASH' - Create a hash of the SIP Call-ID header.

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

#####`listen_policy`

Default syntax expression identifying traffic accepted by the virtual server. Can be either an expression (for example, CLIENT.IP.DST.IN_SUBNET(192.0.2.0/24) or the name of a named expression. In the above example, the virtual server accepts all requests whose destination IP address is in the 192.0.2.0/24 subnet.

#####`listen_priority`

Integer specifying the priority of the listen policy. A higher number specifies a lower priority. If a request matches the listen policies of more than one virtual server the virtual server whose listen policy has the highest priority (the lowest priority number) accepts the request.

Maximum value: 101

#####`macmode_retain_vlan`

This option is used to retain vlan information of incoming packet when macmode is enabled.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`max_autoscale_members`

Maximum number of members expected to be present when vserver is used in Autoscale.

Maximum value: 5000

#####`min_autoscale_members`

Minimum number of members expected to be present when vserver is used in Autoscale.

Maximum value: 5000

#####`mssql_server_version`

For a load balancing virtual server of type MSSQL, the Microsoft SQL Server version. Set this parameter if you expect some clients to run a version different from the version of the database. This setting provides compatibility between the client-side and server-side connections by ensuring that all communication conforms to the server's version.

Valid options: 70, 2000, 2000SP1, 2005, 2008, 2008R2, 2012.

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

Units in which to increment load at each interval in slow-start mode. Possible values = PER_SECOND, PERCENT.

#####`oracle_server_version`

Oracle server version.

Valid options: 10G, 11G.

#####`persist_avp_no`

Persist AVP number for Diameter Persistency. If this AVP is not defined in Base RFC 3588 and it is nested inside a Grouped AVP, define a sequence of AVP numbers (max 3) in order of parent to child. So if persist AVP number X is nested inside AVP Y, which is nested in Z, then you would define the list as  Z Y X.

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

* 'SOURCEIP' - Connections from the same client IP address belong to the same persistence session.
* 'COOKIEINSERT' - Connections that have the same HTTP Cookie, inserted by a Set-Cookie directive from a server, belong to the same persistence session.
* 'SSLSESSION' - Connections that have the same SSL Session ID belong to the same persistence session.
* 'CUSTOMSERVERID' - Connections with the same server ID form part of the same session. For this persistence type, set the Server ID (CustomServerID) parameter for each service and configure the Rule parameter to identify the server ID in a request.
* 'RULE' - All connections that match a user defined rule belong to the same persistence session.
* 'URLPASSIVE' - Requests that have the same server ID in the URL query belong to the same persistence session. The server ID is the hexadecimal representation of the IP address and port of the service to which the request must be forwarded. This persistence type requires a rule to identify the server ID in the request.
* 'DESTIP' - Connections to the same destination IP address belong to the same persistence session.
* 'SRCIPDESTIP' - Connections that have the same source IP address and destination IP address belong to the same persistence session.
* 'CALLID' - Connections that have the same CALL-ID SIP header belong to the same persistence session.
* 'RTSPSID' - Connections that have the same RTSP Session ID belong to the same persistence session.

#####`port`

*Required.* Specifies the port number of the service. Valid options: '*' or integers.

#####`priority_queuing`

Use priority queuing on the virtual server, based persistence types, for IPv6 virtual servers.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`process_local`

By turning on this option packets destined to a vserver in a cluster will not under go any steering. Turn this option for single packet request response mode or when the upstream device is performing a proper RSS for connection based distribution.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`push`

Process traffic with the push virtual server that is bound to this load balancing virtual server.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`push_label_expression`

Expression for extracting a label from the server's response. Can be either an expression or the name of a named expression.

#####`push_multiple_clients`

Allow multiple Web 2.0 connections from the same client to connect to the virtual server and expect updates.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`push_virtual_server_name`

Name of the load balancing virtual server, of type PUSH or SSL_PUSH, to which the server pushes updates received on the load balancing virtual server that you are configuring.

#####`range`

Number of IP addresses that the appliance must generate and assign to the virtual server. The virtual server then functions as a network virtual server, accepting traffic on any of the generated IP addresses. The IP addresses are generated automatically, as follows:

* For a range of n, the last octet of the address specified by the IP Address parameter increments n-1 times.
* If the last octet exceeds 255, it rolls over to 0 and the third octet increments by 1.

Minimum value: 1
Maximum value: 254

#####`recursion_available`

When set to 'YES', this option causes the DNS replies from this vserver to have the RA bit turned on. Typically one would set this option to YES, when the vserver is load balancing a set of DNS servers that support recursive queries.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`redirect_port_rewrite`

Rewrite the port and change the protocol to ensure successful HTTP redirects from services.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

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

~~~
HTTP.RES.HEADER("setcookie").VALUE(0).TYPECAST_NVLIST_T('=',';').VALUE("server1").
~~~

#####`rhi_state`

Route Health Injection (RHI) functionality of the NetSaler appliance for advertising the route of the VIP address associated with the virtual server. When Vserver RHI Level (RHI) parameter is set to VSVR_CNTRLD, the following are different RHI behaviors for the VIP address on the basis of RHIstate (RHI STATE) settings on the virtual servers associated with the VIP address:

* If you set RHI STATE to PASSIVE on all virtual servers, the NetScaler ADC always advertises the route for the VIP address.
* If you set RHI STATE to ACTIVE on all virtual servers, the NetScaler ADC advertises the route for the VIP address if at least one of the associated virtual servers is in UP state.
* If you set RHI STATE to ACTIVE on some and PASSIVE on others, the NetScaler ADC advertises the route for the VIP address if at least one of the associated virtual servers, whose RHI STATE set to ACTIVE, is in UP state.

#####`rtsp_natting`

Use network address translation (NAT) for RTSP data connections.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`rule`

Expression, or name of a named expression, against which traffic is evaluated. Written in the classic or default syntax.

Note: Maximum length of a string literal in the expression is 255 characters. A longer string can be split into smaller strings of up to 255 characters each, and the smaller strings concatenated with the + operator. For example, you can create a 500-character string as follows: '"string of 255 characters" + "string of 245 characters"'.

The following requirements apply only to the NetScaler CLI:

* If the expression includes one or more spaces, enclose the entire expression in double quotation marks.
* If the expression itself includes double quotation marks, escape the quotations by using the  character.
* Alternatively, you can use single quotation marks to enclose the rule, in which case you do not have to escape the double quotation marks.

#####`service_type`

Protocol used by the service (also called the service type).

Valid options: HTTP, FTP, TCP, UDP, SSL, SSL_BRIDGE, SSL_TCP, DTLS, NNTP, DNS, DHCPRA, ANY, SIP_UDP, DNS_TCP, RTSP, PUSH, SSL_PUSH, RADIUS, RDP, MYSQL, MSSQL, DIAMETER, SSL_DIAMETER, TFTP, ORACLE.

#####`sessionless`

Perform load balancing on a per-packet basis, without establishing sessions. Recommended for load balancing of intrusion detection system (IDS) servers and scenarios involving direct server return (DSR), where session information is unnecessary.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`skip_persistency`

Decides the behavior in case the service selected from an existing persistence session has reached threshold.

Valid options: Bypass, ReLb, None.

#####`spillover_backup_action`

Specifies the action to be performed if spillover is to take effect, but no backup chain to spillover is usable or exists.

Valid options: DROP, ACCEPT, REDIRECT.

#####`spillover_method`

Specifies the type of threshold that, when exceeded, triggers spillover. Available settings function as follows:

* CONNECTION - Spillover occurs when the number of client connections exceeds the threshold.
* DYNAMICCONNECTION - Spillover occurs when the number of client connections at the virtual server exceeds the sum of the maximum client (Max Clients) settings for bound services. Do not specify a spillover threshold for this setting, because the threshold is implied by the Max Clients settings of bound services.
* BANDWIDTH - Spillover occurs when the bandwidth consumed by the virtual server's incoming and outgoing traffic exceeds the threshold.
* HEALTH - Spillover occurs when the percentage of weights of the services that are UP drops below the threshold. For example, if services svc1, svc2, and svc3 are bound to a virtual server, with weights 1, 2, and 3, and the spillover threshold is 50%, spillover occurs if svc1 and svc3 or svc2 and svc3 transition to DOWN.
* NONE - Spillover does not occur.

#####`spillover_persistence`

If spillover occurs, maintain source IP address based persistence for both primary and backup virtual servers.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`spillover_persistence_timeout`

Timeout for spillover persistence, in minutes.

Minimum value: 2
Maximum value: 1440

#####`spillover_threshold`

Threshold at which spillover occurs. Specify an integer for the CONNECTION spillover method, a bandwidth value in kilobits per second for the BANDWIDTH method (do not enter the units), or a percentage for the HEALTH method (do not enter the percentage symbol).

Minimum value: 1
Maximum value: 4294967287

#####`state`

State of the load balancing virtual server.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`sure_connect`

Use SureConnect on the virtual server.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

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

Insert an HTTP header, whose value is the IP address and port number of the virtual server, before forwarding a request to the server. The format of the header is `<vipHeader>: <virtual server IP address>_<port number>`, where vipHeader is the name that you specify for the header. If the virtual server has an IPv6 address, the address in the header is enclosed in brackets ([ and ]) to separate it from the port number. If you have mapped an IPv4 address to a virtual server's IPv6 address, the value of this parameter determines which IP address is inserted in the header, as follows:

* VIPADDR - Insert the IP address of the virtual server in the HTTP header regardless of whether the virtual server has an IPv4 address or an IPv6 address. A mapped IPv4 address, if configured, is ignored.
* V6TOV4MAPPING - Insert the IPv4 address that is mapped to the virtual server's IPv6 address. If a mapped IPv4 address is not configured, insert the IPv6 address.
* OFF - Disable header insertion.

###Type: netscaler_lbvserver_responderpolicy_binding

Manages a binding between a load balancing vserver and a responder policy.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`

The basic state that the resource should be in. Valid values are 'present', 'absent'.

#####`goto_expression`

Expression specifying the priority of the next policy that gets evaluated if the current policy rule evaluates to true.

#####`invoke_policy_label`

Label of policy to invoke if the bound policy evaluates to true.

#####`invoke_vserver_label`

Label of vserver to invoke if the bound policy evaluates to true.

#####`name`

The title of the bind resource, composed of the title of the lbvserver and the title of the policy: 'lbvserver_name/policy_name'.

#####`priority`

The priority of the policy binding. Values can  be any integer between 1 and 2147483647.

### netscaler_lbvserver_responderpolicy_binding

Manage a binding between a load balancing vserver and a responder policy.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`goto_expression`

Specifies the priority of the next policy to be evaluated if the current policy rule evaluates to true.

#####`invoke_policy_label`

Label of the policy to invoke if the bound policy evaluates to true.

#####`invoke_vserver_label`

Label of the vserver to invoke if the bound policy evaluates to true.

#####`name`

The title of the bind resource, composed of the title of the lbvserver and the title of the policy: 'lbvserver_name/policy_name'.

#####`priority`

The priority of the policy binding. Values can  be any integer between 1 and 2147483647.

### netscaler\_lbvserver\_rewritepolicy_binding

Manage a binding between a loadbalancing vserver and a rewrite policy.

#### Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

##### `ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

##### `goto_expression`

Specifies the priority of the next policy to be evaluated if the current policy rule evaluates to true.

##### `invoke_policy_label`

Label of the policy to invoke if the bound policy evaluates to true.

##### `invoke_vserver_label`

Label of the vserver to invoke if the bound policy evaluates to true.

##### `bind_point`

Bind point to which the policy should be bound.

#####`name`

The title of the bind resource, composed of the title of the lbvserver and the title of the policy: 'lbvserver_name/policy_name'.

#####`priority`

The priority of the policy binding. Values can  be any integer between 1 and 65536.

###Type: netscaler_lbserver_service_binding

Manages a binding between a load balancing vserver and a service.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`name`

The title of the bind resource, composed of the title of the lbvserver and the title of the service: 'lbvserver_name/service_name'.

#####`weight`

Weight to assign to the specified service. Value can be any integer between 1 and 100.

###Type: netscaler_nshostname

Manages NetScaler NTP server objects.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`name`

Host name for the NetScaler appliance.

#####`ownernode`

ID of the cluster node for which you are setting the hostname. This can be configured only through the cluster IP address.

Minimum value = 0
Maximum value = 31

###Type: netscaler_nsip

Manages basic NetScaler network IP objects.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`allow_ftp`

Allows File Transfer Protocol (FTP) access to this IP address.

Valid options: Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'. Default value: 'ENABLED'.

#####`allow_gui`

Allows graphical user interface (GUI) access to this IP address.

Valid options: 'ENABLED', 'SECUREONLY', 'DISABLED'. Default value: 'ENABLED'.

#####`allow_management_access`

Allows access to management applications on this IP address.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'. Default value: 'DISABLED'.

#####`allow_snmp`

Allows Simple Network Management Protocol (SNMP) access to this IP address.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'. Default value: 'ENABLED'.

#####`allow_ssh`

Allows secure shell (SSH) access to this IP address.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'. Default value: 'ENABLED'.

#####`allow_telnet`

Allows Telnet access to this IP address.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'. Default value: 'ENABLED'.

#####`arp`

Responds to ARP requests for this IP address.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'. Default value: 'ENABLED'.

#####`arp_response`

Responds to ARP requests for a Virtual IP (VIP) address on the basis of the states of the virtual servers associated with that VIP. Available settings function as follows:

* 'NONE' - The NetScaler appliance responds to any ARP request for the VIP address, irrespective of the states of the virtual servers associated with the address.
* 'ONE_VSERVER' - The NetScaler appliance responds to any ARP request for the VIP address if at least one of the associated virtual servers is in UP state.
* 'ALL_VSERVER' - The NetScaler appliance responds to any ARP request for the VIP address if all of the associated virtual servers are in UP state.

#####`dynamic_routing

Allows dynamic routing on this IP address. Specific to Subnet IP (SNIP) address.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'. Default value: 'DISABLED'.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`host_route`

Advertises a route for the VIP address using the dynamic routing protocols running on the NetScaler appliance.
Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`host_route_gateway_ip`

IP address of the gateway of the route for this VIP address.

#####`host_route_metric`

Integer value to add to or subtract from the cost of the route advertised for the VIP address.

Minimum value = -16777215

#####`icmp`

Responds to ICMP requests for this IP address.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'. Default value: 'ENABLED'.

#####`icmp_response`

Responds to ICMP requests for a Virtual IP (VIP) address on the basis of the states of the virtual servers associated with that VIP. Available settings function as follows:

* 'NONE' - The NetScaler appliance responds to any ICMP request for the VIP address, irrespective of the states of the virtual servers associated with the address.
* 'ONE_VSERVER' - The NetScaler appliance responds to any ICMP request for the VIP address if at least one of the associated virtual servers is in UP state.
* 'ALL_VSERVER' - The NetScaler appliance responds to any ICMP request for the VIP address if all of the associated virtual servers are in UP state.
* 'VSVR_CNTRLD' - The behavior depends on the `icmp_virtual_server_response` property setting on all the associated virtual servers.

The following values can be set for the `icmp_virtual_server_response` property on a virtual server:

* If you set the `icmp_virtual_server_response` property to `active` on all virtual servers, NetScaler always responds.
* If you set the `icmp_virtual_server_response` property to `active` on all virtual servers, NetScaler responds if even one virtual server is UP.
* When you set the `icmp_virtual_server_response` property to `active` on some and `passive` on others, NetScaler responds if even one virtual server set to `active` is UP.

Possible values = 'NONE', 'ONE_VSERVER', 'ALL_VSERVERS', 'VSVR_CNTRLD'.

#####`ip_address`

IPv4 address to create on the NetScaler appliance. Cannot be changed after the resource is created. If omitted, this parameter's value defaults to the resource's title.

#####`ip_type`

Type of the IP address to create on the NetScaler appliance. Cannot be changed after the IP address is created. The following are the different types of NetScaler owned IP addresses:

* A Subnet IP (SNIP) address is used by the NetScaler ADC to communicate with the servers. The NetScaler also uses the subnet IP address when generating its own packets, such as packets related to dynamic routing protocols, or to send monitor probes to check the health of the servers.
* A Virtual IP (VIP) address is the IP address associated with a virtual server. It is the IP address to which clients connect. An appliance managing a wide range of traffic may have many VIPs configured. Some of the attributes of the VIP address are customized to meet the requirements of the virtual server.
* A GSLB site IP (GSLBIP) address is associated with a GSLB site. It is not mandatory to specify a GSLBIP address when you initially configure the NetScaler appliance. A GSLBIP address is used only when you create a GSLB site.
* A Cluster IP (CLIP) address is the management address of the cluster. All cluster configurations must be performed by accessing the cluster through this IP address.

Default value: SNIP
Possible values = SNIP, VIP, NSIP, GSLBsiteIP, CLIP

#####`netmask

*Required.* Subnet mask associated with the IP address.

#####`ospf_area`

ID of the area in which the type1 link-state advertisements (LSAs) are to be advertised for this virtual IP (VIP) address by the OSPF protocol running on the NetScaler appliance. If this parameter is not set, the VIP is advertised on all areas.

Default value: -1
Minimum value = 0
Maximum value = 4294967294LU

#####`ospf_lsa_type`

Type of LSAs to be used by the OSPF protocol, running on the NetScaler appliance, for advertising the route for this VIP address.

Valid values: 'TYPE1', 'TYPE5', 'DISABLED'. Default value: 'DISABLED'.

#####`secure_access_only`

Blocks access to nonmanagement applications on this IP. This option is applicable for MIPs, SNIPs, and NSIP, and is disabled by default. Nonmanagement applications can run on the underlying NetScaler Free BSD operating system.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'. Default value: 'DISABLED'.

#####`state`

Enables or disables the IP address.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'. Default value: 'ENABLED'.

#####`traffic_domain`

Integer value that uniquely identifies the traffic domain in which you want to configure the entity. If you do not specify an ID, the entity becomes part of the default traffic domain, which has an ID of 0.

Minimum value = 0
Maximum value = 4094

#####`virtual_router_id`

A positive integer that uniquely identifies a VMAC address for binding to this VIP address. This binding is used to set up NetScaler appliances in an active-active configuration using VRRP.

Minimum value = 1
Maximum value = 255

#####`virtual_server

Enables or disables the virtual server attribute for this IP address.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'. Default value: 'ENABLED'.

#####`virtual_server_rhi_level`

Advertise the route for the Virtual IP (VIP) address on the basis of the state of the virtual servers associated with that VIP.

* 'NONE' - Advertise the route for the VIP address, regardless of the state of the virtual servers associated with the address.
* 'ONE_VSERVER' - Advertise the route for the VIP address if at least one of the associated virtual servers is in UP state.
* 'ALL_VSERVER' - Advertise the route for the VIP address if all of the associated virtual servers are in UP state.
* 'VSVR_CNTRLD' - Advertise the route for the VIP address according to the `rhi_state` property value on all the associated virtual servers of the VIP address along with their states.

When Vserver `rhi_state` property is set to 'VSVR_CNTRLD', the following are different RHI behaviors for the VIP address on the basis of the `rhi_state` property on the virtual servers associated with the VIP address:

* If you set `rhi_state` to `passive` on all virtual servers, the NetScaler ADC always advertises the route for the VIP address.
* If you set `rhi_state` to `active` on all virtual servers, the NetScaler ADC advertises the route for the VIP address if at least one of the associated virtual servers is in UP state.
*If you set `rhi_state` to `active` on some and PASSIVE on others, the NetScaler ADC advertises the route for the VIP address if at least one of the associated virtual servers, whose `rhi_state` is set to `active`, is in UP state.

Default value: 'ONE_VSERVER'.

#####`virtual_server_rhi_mode`

Advertise the route for the Virtual IP (VIP) address using dynamic routing protocols or using RISE. Valid values:

* DYNAMIC_ROUTING - Advertise the route for the VIP address using dynamic routing protocols (default)
* RISE - Advertise the route for the VIP address using RISE.

Default value: DYNAMIC_ROUTING.

###Type: netscaler_ntpserver

Manage NetScaler NTP server objects.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`auto_key`

Use the Autokey protocol for key management for this server, with the cryptographic values (for example, symmetric key, host and public certificate files, and sign key) generated by the ntp-keygen utility. To require authentication for communication with the server, you must set either the value of this parameter or the key parameter.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`key`

Key to use for encrypting authentication fields. All packets sent to and received from the server must include authentication fields encrypted by using this key. To require authentication for communication with the server, you must set either the value of this parameter or the autokey parameter.

Minimum value = 1
Maximum value = 65534

#####`maximum_poll_interval`

Maximum time after which the NTP server must poll the NTP messages. In seconds, expressed as a power of 2.

Minimum value = 4
Maximum value = 17

#####`minimum_poll_interval`

Minimum time after which the NTP server must poll the NTP messages. In seconds, expressed as a power of 2.

Minimum value = 4
Maximum value = 17

#####`name`

IP address or fully qualified domain name of the NTP server.

#####`preferred_ntp_server`

Preferred NTP server. The NetScaler appliance chooses this NTP server for time synchronization among a set of correctly operating hosts.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'. Default value: 'NO'.

###Type: netscaler_ntpsync

Manage NetScaler NTP sync setting. Only one `netscaler_ntpsync` resource may be declared per device.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`

The basic state that the resource should be in. A value of 'present' allows the state to be managed, but 'absent' always disables ntp sync.

Valid values are 'present', 'absent'.

#####`state`

NTP status.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'. If omitted, this parameter's value defaults to the resource's title.

###Type: netscaler_responderaction

Manages basic NetScaler responder action objects.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`bypass_safety_check`

Bypass the safety check, allowing potentially unsafe expressions.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`comments`

Any comments you want to associate with the responder action.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`expression`

Expression specifying what to respond with. Typically a URL for redirect policies or a default-syntax expression.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`type`

Type of responder action. Type of responses sent by the policies bound to this policy label. Valid options: 'noop', 'respondwith', 'redirect', 'sqlresponse_ok', 'sqlresponse_error'.


###Type: netscaler_responderglobal

Activates the specified responder policy for all requests sent to the NetScaler appliance.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`goto_expression`

Expression specifying the priority of the next policy that gets evaluated if the current policy rule evaluates to true.

#####`invoke_policy_label`

Label of policy to invoke if the bound policy evaluates to true.

#####`invoke_vserver_label`

The label of the lbvserver to invoke if the bound policy evaluates to true.

#####`name`

Name for the responder policy. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`priority`

Specifies the priority of the policy. Values can be any integer between 1 and 2147483647.

###Type: netscaler_responderpolicy

Manages basic NetScaler responder policy objects.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`action`

Name of the responder action to perform if the request matches this responder policy.

#####`appflow_action`

AppFlow action to invoke for requests that match this policy.

#####`comments`

Any comments about this responder policy.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`expression`

Default syntax expression that the policy uses to determine whether to respond to the specified request.

#####`log_action`

Name of the messagelog action to use for requests that match this policy.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`undefined_result_action`

Action to perform if the result of policy evaluation is undefined.

###Type: netscaler_responderpolicylabel

Manages basic NetScaler responder policy label objects.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`comments`

Any comments to preserve information about this responder policy label.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`type`

Type of responses sent by the policies bound to this policy label. Valid options: HTTP, OTHERTCP, SIP_UDP, MYSQL, MSSQL, NAT, DIAMETER.

###Type: netscaler_rewriteaction

Manages basic NetScaler rewrite action objects.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`bypass_safety_check`

Bypass the safety check and allow unsafe expressions.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`comments`

Comments associated with this rewrite action.

#####`content_expression`

Default syntax expression that specifies the content to insert into the request or response at the specified location, or that replaces the specified string. Applicable for the following types: INSERT_HTTP_HEADER, INSERT_SIP_HEADER, REPLACE, INSERT_BEFORE, INSERT_AFTER, REPLACE_ALL, INSERT_BEFORE_ALL, INSERT_AFTER_ALL.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`pattern`

Pattern to be used for INSERT_BEFORE_ALL, INSERT_AFTER_ALL, REPLACE_ALL, DELETE_ALL action types.

#####`refine_search`

The refineSearch expression specifies how the selected HTTP data can further be refined.

Maximum length of the input expression is 8191. Maximum size of string that can be used inside the expression is 1499.

#####`search`

Search expression takes one of five arguments to use the appropriate methods to search in the specified body or header. For example:

~~~
search => 'text("hello")'
~~~

or

~~~
search => 'regex(re/^hello/)'
~~~


* `text(string)`. Example: `text("hello")`.
* `regex(re<delimiter>regular exp<delimiter>)`. Example: `regex(re/^hello/)`.
* `xpath(xp<delimiter>xpath expression<delimiter>)`. Example: `xpath(xp%/a/b%)`.
* `xpath_json(xp<delimiter>xpath expression<delimiter>)`. Example: `xpath_json(xp%/a/b%)`. Note that `xpath_json_search` takes xpath expression as argument but operates on json file instead of xml file.
* `patset(patset)`. Example: `patset("patset1")`.

Search is a superset of pattern.  We recommend using `search` rather than `pattern`.

#####`target_expression`

Default syntax expression that specifies which part of the request or response to rewrite.

#####`type`

Type of rewrite action. Accepts the following: 'replace', 'insert_http_header', 'delete_http_header', corrupt_http_header', 'insert_before', 'insert_after', 'delete', 'replace_http_res'.

For each action, use the `<target_expression>` and `<content_expression>` as defined below.

* `insert_http_header`: Inserts a HTTP header.

  `<target_expression>` = header name

  `<content_expression>` = header value specified as a compound text expression

* `insert_sip_header`: Inserts a SIP header.

  `<target_expression>` = header name

  `<content_expression>` = header value specified as a compound text expression

* `delete_http_header`: Deletes all occurrence of HTTP header.

  `<target_expression>` = header name

* `delete_sip_header`: Deletes all occurrence of SIP header.

  `<target_expression>` = header name

* `corrupt_http_header`: Corrupts all occurrence of HTTP header.

  `<target_expression>` = header name

* `corrupt_sip_header`: Corrupts all occurrence of SIP header.

  `<target_expression>` = header name

* `replace`: Replaces the target text reference with the value specified in attr.

  `<target_expression>` = Advanced text expression

  `<content_expression>` = Compound text expression

* `insert_before`: Inserts the value specified by attr before the target text reference.

 `<target_expression>` = Advanced text expression

 `<content_expression>` = Compound text expression

* `insert_after`: Inserts the value specified by attr after the target text reference.

  `<target_expression>` = Advanced text expression

  `<content_expression>` = Compound text expression

* `delete`: Deletes the target text reference.

  `<target_expression>` = Advanced text expression

* `replace_http_res`: Replaces the http response with value specified in target.

  `<target_expression>` = Compound text expression

* `replace_sip_res`: Replaces the SIP response with value specified in target.

  `<target_expression>` = Compound text expression

* `replace_all`: Replaces all occurrence of the pattern in the text provided in the target with the text provided in the stringBuilderExpr, with a string defined in the `-pattern`  or `-search` parameters.


  For example, you can replace all occurrences of 'abcd':

  ~~~
  replace_all => true,
  pattern     => 'efgh.*'
  ~~~

  or

  ~~~
  replace_all => true,
  search      => 'aoeu'
  ~~~

  `<target_expression>` = Text in a request or a response.

  `<content_expression>` = Compound text expression.

  `-pattern <expression>` = String constant, for example `pattern => efgh` or `search => text("efgh")`.

* `insert_before_all`: Inserts the value specified by `<content_expression>` before all the occurrence of pattern in the target text reference.

  `<target_expression>` = Advanced text expression.

  `<content_expression>` = Compound text expression.

   The `pattern` and `search` parameters accept either a string or a regex: `pattern => <expression>`, `search => regex(<regular expression>)` or `search => text(string constant)`.

* `insert_after_all`: Inserts the value specified by `<content_expression>` after all the occurrences of the pattern specified in the target text reference.

  `<target_expression>` = Advanced text expression.

  `<content_expression>` = Compound text expression.

  The `pattern` and `search` parameters accept either a string or a regex: `pattern => <expression>`, `search => regex(<regular expression>)` or `search => text(string constant)`.

* `delete_all`: Delete all the occurrence of pattern in the target text reference.

  `<target_expression>` = Advanced text expression.

  The `pattern` and `search` parameters accept either a string or a regex: `pattern => <expression>`, `search => regex(<regular expression>)` or `search => text(string constant)`.

###Type: netscaler_rewriteglobal

Activates the specified rewrite policy for all requests sent to the NetScaler appliance.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`connection_type`

Type of invocation when invoking a vserver. Available settings function as follows:

  * Request: Forwards the request to the specified request virtual server.
  * Response: Forwards the response to the specified response virtual server.

This parameter can not be used in conjunction with invoking a Policy Label.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`goto_expression`

Expression specifying the priority of the next policy that gets evaluated if the current policy rule evaluates to true.

#####`invoke_policy_label`

Label of policy to invoke if the bound policy evaluates to true.

#####`invoke_vserver_label`

Label of lbvserver to invoke if the bound policy evaluates to 'true'.

#####`name`

Name for the rewrite policy. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`priority`

Specifies the priority of the policy. Values can be any integer between 1 and 2147483647.

###Type: netscaler_rewritepolicy

Manage basic NetScaler rewrite policy objects.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`action`

Rewrite action to be used by the policy.

#####`comments`

Comments associated with this rewrite policy.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`expression`

Expression against which traffic is evaluated. Written in default syntax.

#####`log_action`

The log action associated with the rewrite policy.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`undefined_result_action`

A rewrite action, to be used by the policy when the rule evaluation turns out to be undefined. The undef action can be NOREWRITE, RESET or DROP.

###Type: netscaler_rewritepolicylabel

Manage basic NetScaler rewrite policy label objects.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`comments`

Any comments to preserve information about this rewrite policy label.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`transform_name`

Types of transformations allowed by the policies bound to the label. The following types are supported:

  * `http_req` - HTTP requests
  * `http_res` - HTTP responses
  * `othertcp_req` - Non-HTTP TCP requests
  * `othertcp_res` - Non-HTTP TCP responses
  * `url` - URLs
  * `text` - Text strings
  * `clientless_vpn_req` - NetScaler clientless VPN requests
  * `clientless_vpn_res` - NetScaler clientless VPN responses
  * `sipudp_req` - SIP requests
  * `sipudp_res` - SIP responses
  * `diameter_req` - DIAMETER requests
  * `diameter_res` - DIAMETER responses

###Type: netscaler_route

The IPv4 network address, netmask and gateway, in the format 'network/netmask:gateway':

~~~
8.8.8.0/255.255.255.0:null
~~~

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`advertise`

Advertises this route.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`cost1`

Specifies the cost used by the routing algorithms to determine preference for using this route. The lower the cost, the higher the preference. Accepts any positive integer between 0 and 65535.

#####`distance`

Specifies the administrative distance of this route. This determines the preference of this route over other routes with same destination, from different routing protocols. A lower value is preferred. Accepts any integer between 0 and 255. Default value: 1.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`monitor`

Name of the monitor, of type ARP or PING, configured on the NetScaler appliance to monitor this route.

#####`msr`

Whether to monitor this route using a monitor of type ARP or PING.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`protocol`

Routing protocol used for advertising this route.

Valid options: 'OSPF', 'ISIS', 'RIP', 'BGP'. Default value: ADV_ROUTE_FLAGS.

#####`td`
Uniquely identifies the traffic domain in which you want to configure the entity. If you do not specify an ID, the entity becomes part of the default traffic domain, which has an ID of 0. Accepts any integer from 0 to 4094.

#####`weight`

Determine preference for this route over others of equal cost. The lower the weight, the higher the preference. Accepts an integer from 1 to 65535.

###Type: netscaler_server

Manages basic NetScaler server objects, either IP address-based servers or domain-based servers.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`address`
Specifies the domain name, IPv4 address, or IPv6 address of the server.

Valid options: 'ipv4', 'ipv6', or 'domain name'

#####`comments`
Provides any necessary or additional information about the server.

Valid options: a string.

#####`disable_wait_time`
Specifies a wait time when disabling a server object. During the wait time, the server object continues to handle established connections but rejects new connections.

Valid options: an integer.

#####`ensure`
Determines whether the server object is present or absent.

Valid values are 'present', 'absent'.

#####`graceful_shutdown`
Enables graceful shutdown of the server, in which the system will wait for all outstanding connections to the server to be closed before disabling it.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`ipv6_domain`
Supports IPv6 addressing mode. If you configure a server with the IPv6 addressing mode, you cannot use the server in the IPv4 addressing mode

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`name`

Name for the server. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`resolve_retry`
Sets the time, in seconds, the NetScaler appliance must wait after DNS resolution fails before sending the next DNS query to resolve the domain name.

Valid options: an integer; maximum = 20939 and minimum = 5 Default: 5

#####`state`
Sets the state of the server.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`traffic_domain_id`
Specifies the integer value that uniquely identifies the traffic domain in which you want to configure the entity. If you do not specify an ID, the entity becomes part of the default traffic domain.

Valid options: an integer; minimum = 0 and maximum = 4096 Default: 0

#####`translation_ip_address`
Specifies the IP address used to transform the server's DNS-resolved IP address.

Valid options: IP address.

#####`translation_mask`
Sets the netmask of the translation IP.

Valid options: IP netmask.

###Type: netscaler_service

Manages service representation objects for NetScaler server entries. If the service is domain-based, you must use the `add server` command to create the 'server' entry before you create the service. Then, specify the server parameter in the `add server` command.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`access_down`
Determines whether to use Layer 2 mode to bridge the packets sent to the service if it is marked as DOWN. If the service is DOWN and this parameter is disabled, the packets are dropped.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`appflow_logging`
Enables logging of AppFlow information.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`cache_type`
Specifies the cache type supported by the cache server.

Valid options: 'SERVER', 'TRANSPARENT', 'REVERSE', or 'FORWARD'.

#####`cacheable`
Uses the transparent cache redirection virtual server to forward requests to the cache server. May not be specified if `cache_type` is 'TRANSPARENT', 'REVERSE', or 'FORWARD'.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`clear_text_port`
Sets the port to which clear text data must be sent after the appliance decrypts incoming SSL traffic. Applicable to transparent SSL services.

Valid options: an integer

#####`client_idle_timeout`
Specifies the time, in seconds, after which to terminate an idle client connection.

Valid options: an integer; max = 31536000s

#####`client_ip`
Determines whether to insert an HTTP header with the client's IPv4 or IPv6 address as its value before forwarding a request to the service. Use if the server needs the client's IP address for security, accounting, or other purposes, and setting the `use_source_ip` parameter is not a viable option.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`client_ip_header`
Specifies the name for the HTTP header whose value must be set to the IP address of the client. Used with the `client_ip` parameter.

If you set `client_ip` and you do not specify a name for the header, the appliance uses the header name specified for the global `client_ip_header` parameter. If the global `client_ip_header` parameter is not specified, the appliance inserts a header with the name "client-ip."

Valid options: a string.

#####`client_keepalive`

Enables client keep-alive for the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`comments`
Provides any necessary or additional information about the service.

Valid options: a string.

#####`down_state_flush`
Flushes all active transactions associated with a service whose state transitions from UP to DOWN. Do not enable this option for applications that must complete their transactions.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`ensure`
Determines whether the service is present or absent.

Valid options: 'present' or 'absent'.

#####`graceful_shutdown`
Enables graceful shutdown of the server, meaning the system will wait for all outstanding connections to this server to be closed before disabling it.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`hash_id`
Specifies a numerical identifier to be used by hash-based load balancing methods. Must be unique for each service.

Valid options: an integer; minimum = 1

#####`health_monitoring`
Monitors the health of this service. Enabling this parameter sends probes to check the health of the service. Disabling this parameter means no probes are sent to check the health of the service, and the appliance shows the service as UP at all times.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

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

Name for the server. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`port`

*Required.* Specifies the port number of the service.

Valid options: '*' or Integers.

#####`protocol`

*Required.* Specifies the protocol in which data is exchanged with the service.

Valid options: 'HTTP', 'FTP', 'TCP', 'UDP', 'SSL', 'SSL_BRIDGE', 'SSL_TCP', 'DTLS', 'NNTP', 'RPCSVR', 'DNS', 'ADNS', 'SNMP', 'RTSP', 'DHCPRA', 'ANY', 'SIP_UDP', 'DNS_TCP', 'ADNS_TCP', 'MYSQL', 'MSSQL', 'ORACLE', 'RADIUS', 'RDP', 'DIAMETER', 'SSL_DIAMETER', or 'TFTP'.

#####`server_id`
Specifies a unique identifier for the service. Used when the persistency type for the virtual server is set to 'Custom Server ID'.

Valid options: a string.

#####`server_idle_timeout`
Sets the time, in seconds, after which to terminate an idle server connection.

Valid options: Integers; maximum = 31536000

#####`server_name`
*Required.* Specifies the name of the server that hosts the service.

Valid options: a string.

#####`state`
Sets the state of the node resource.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`sure_connect`
Sets the state of SureConnect for the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`surge_protection`
Enables surge protection for the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`tcp_buffering`
Enables TCP buffering for the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`traffic_domain_id`
Specifies the integer value that uniquely identifies the traffic domain in which you want to configure the entity. If you do not specify an ID, the entity becomes part of the default traffic domain.

Valid options: an integer; minimum = 0 and maximum = 4096

#####`use_proxy_port`
Uses the proxy port as the source port when initiating connections with the server. Disabling this parameter means the client-side connection port is used as the source port for the server-side connection. This parameter is available only when the `use_source_ip` parameter is enabled.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`use_source_ip`
Uses the client's IP address as the source IP address when initiating a connection to the server. When creating a service, if you do not set this parameter, the service inherits the global Use Source IP setting (available in the enable ns mode and disable ns mode CLI commands, or in the System > Settings > Configure modes > Configure Modes dialog box). However, you can override this setting after you create the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`use_compression`
Enable compression for the service.

Possible values: YES, NO

###Type: netscaler_servicegroup

Enables you to manage a group of services. For example, if you enable or disable any option, such as compression, health monitoring, or graceful shutdown for a service group, the option is enabled for all the members of the service group.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`appflow_logging`

Enables logging of AppFlow information.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`autoscale_mode`

Auto scale option for a servicegroup. Valid options: 'DISABLED', 'DNS', or 'POLICY'.

#####`cache_type`

Cache type supported by the cache server. Valid options: 'SERVER', 'TRANSPARENT', 'REVERSE', or 'FORWARD'.

#####`cacheable`

Uses the transparent cache redirection virtual server to forward requests to the cache server. Must not be specified if cache_type is 'TRANSPARENT', 'REVERSE', or 'FORWARD'.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`client_idle_timeout`

Specifies the time, in seconds, after which to terminate an idle client connection.

Max = 31536000.

#####`client_ip`

Inserts an HTTP header with the client's IPv4 or IPv6 address as its value, before forwarding a request to the service. Used if the server needs the client's IP address for security, accounting, or other purposes, and setting the Use Source IP parameter is not a viable option.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`client_ip_header`

Name for the HTTP header whose value must be set to the IP address of the client. Used with the Client IP parameter. If you set the Client IP parameter, and you do not specify a name for the header, the appliance uses the header name specified for the global Client IP Header parameter. If the global Client IP Header parameter is not specified, the appliance inserts a header with the name "client-ip."

#####`client_keepalive`

Enables client keep-alive for the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`comments`

Any comments you want associated with this object.

#####`down_state_flush`

Flushes all active transactions associated with a service whose state transitions from UP to DOWN. Do not enable this option for applications that must complete their transactions.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`graceful_shutdown`

Indicates graceful shutdown of the server. System will wait for all outstanding connections to this server to be closed before disabling the server.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`health_monitoring`

Monitors the health of this service. Available settings function as follows:

* YES (or any 'true' value) - Send probes to check the health of the service.
* NO (or any 'false' value) - Do not send probes to check the health of the service. With the NO option, the appliance shows the service as UP at all times.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`http_compression`

Enables compression for the specified service.

Valid values: 'YES', 'NO'.

#####`http_profile`

Name of the HTTP profile that contains HTTP configuration settings for the service group.

#####`max_clients`

Maximum number of simultaneous open connections to the service. Accepts an integer.

Max = 4294967294.

#####`max_requests`

Maximum number of requests that can be sent on a persistent connection to the service. Connection requests beyond this value are rejected. Accepts an integer.

Max = 65535.

#####`maximum_bandwidth`

Maximum bandwidth, in Kbps, allocated to the service. Accepts an integer.

Max = 4294967287.

#####`member_port`

The port for the service group members. Only valid when autoscale_mode is POLICY.

#####`monitor_threshold`

Minimum sum of weights of the monitors that are bound to this service. Used to determine whether to mark a service as UP or DOWN. Accepts an integer.

Max = 65535.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`net_profile`

Network profile for the service group.

Minimum length = 1
Maximum length = 127

#####`protocol`

*Required*. Protocol in which data is exchanged with the service group.

Valid options: HTTP, FTP, TCP, UDP, SSL, SSL_BRIDGE, SSL_TCP, DTLS, NNTP, RPCSVR, DNS, ADNS, SNMP, RTSP, DHCPRA, ANY, SIP_UDP, DNS_TCP, ADNS_TCP, MYSQL, MSSQL, ORACLE, RADIUS, RDP, DIAMETER, SSL_DIAMETER, TFTP.

#####`server_idle_timeout`

Time, in seconds, after which to terminate an idle server connection. Accepts an integer.

Max = 31536000.

#####`state`

The state of the object.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`sure_connect`

The state of SureConnect for the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`surge_protection`

Enables surge protection for the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`tcp_buffering`

Enables TCP buffering for the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`tcp_profile`

Name of the TCP profile that contains TCP configuration settings for the service group.

#####`traffic_domain_id`

Uniquely identifies the traffic domain in which you want to configure the entity. If you do not specify an ID, the entity becomes part of the default traffic domain, which has an ID of 0. Accepts an integer from 0 to 4096

#####`use_client_ip`

Whether to use the client's IP address as the source IP address when initiating a connection to the server. When creating a service, if you do not set this parameter, the service inherits the global Use Source IP setting. However, you can override this setting after you create the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`use_proxy_port`

Whether to use the proxy port as the source port when initiating connections with the server. With the NO setting, the client-side connection port is used as the source port for the server-side connection.

Note: This parameter is available only when the `use_client_ip` property is enabled.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.


###Type: netscaler_servicegroup_lbmonitor_binding

Manage a binding between a servicegroup and a loadbalancing monitor.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`name`
The title of the bind resource, composed of the title of the service group and the title of the lbmonitor: 'servicegroup_name/lbmonitor_name'.

#####`passive`

Indicates if the monitor is passive. A passive monitor does not remove servicegroup from LB decision when the threshold is breached.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`state`

The configured state (enable/disable) of the bound monitor.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`weight`

Weight to assign to the monitor-servicegroup binding. When a monitor is UP, the weight assigned to its binding with the servicegroup determines how much the monitor contributes toward keeping the health of the servicegroup above the value configured for the Monitor Threshold parameter. Accepts an integer from 1 to 100.

###Type: netscaler_servicegroup_member

Manages a member of a servicegroup.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`name`

The title of the bind resource, composed of the title of the service group and the title of the server port: 'servicegroup_name/server_name:server_port'.

#####`state`

The configured state (enable/disable) of the service group.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`weight`

Weight to assign to the servers in the service group. Specifies the capacity of the servers relative to the other servers in the load balancing configuration. The higher the weight, the higher the percentage of requests sent to the service. Accepts an integer from 1 to 100.

###Type: netscaler_service_lbmonitor_binding

Manages a binding between a NetScaler service representation object and a load balancing monitor.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`

Determines whether the monitor-service binding is present or absent.

Valid values are 'present' or 'absent'.

#####`name`

Name for the monitor-service binding. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`passive`

Sets the monitor as passive. A passive monitor does not remove service from LB decision when the threshold is breached.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`state`

Determines whether the bound monitor is enabled or disabled.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

#####`weight`

Specifies the weight to assign to the monitor-service binding. When a monitor is UP, the weight assigned to its binding with the service determines how much the monitor contributes toward keeping the health of the service above the value configured for the [`monitor_threshold`](#monitor_threshold) parameter.

Valid options: an integer between 1 and 100.

###Type: netscaler_snmpalarm

Manages NetScaler snmp alarms.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`alarm_threshold`

Value for the high threshold. The NetScaler appliance generates an SNMP trap message when the value of the attribute associated with the alarm is greater than or equal to the specified high threshold value.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`logging`

Logging status of the alarm. When logging is enabled, the NetScaler appliance logs every trap message that is generated for this alarm.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'. Default: 'ENABLED'.

#####`name`

Name of the SNMP alarm. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`normal_threshold`

Value for the normal threshold. A trap message is generated if the value of the respective attribute falls to or below this value after exceeding the high threshold.

Valid values are positive integers.

#####`severity`

Severity level assigned to trap messages generated by this alarm. The severity levels are, in increasing order of severity: Informational, Warning, Minor, Major, and Critical.

#####`state`

Current state of the SNMP alarm. The NetScaler appliance generates trap messages only for SNMP alarms that are enabled.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'. Default: 'enabled'.

#####`time_interval`

Interval, in seconds, at which the NetScaler appliance generates SNMP trap messages when the conditions specified in the SNMP alarm are met. Default value: 1. Can be specified for the following alarms:

* SYNFLOOD
* HA-VERSION-MISMATCH
* HA-SYNC-FAILURE
* HA-NO-HEARTBEATS
* HA-BAD-SECONDARY-STATE
* CLUSTER-NODE-HEALTH
* CLUSTER-NODE-QUORUM
* CLUSTER-VERSION-MISMATCH
* PORT-ALLOC-FAILED
* APPFW traps.

Default trap time intervals: SYNFLOOD and APPFW traps = 1sec, PORT-ALLOC-FAILED = 3600sec(1 hour), Other Traps = 86400sec(1 day).

### netscaler_sslcertkey

Configures the Imported Certfile resource.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`bundle`

Parse the certificate chain as a single file after linking the server certificate to its issuer's certificate within the file.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'. Default: false.

#####`certificate_filename`

Name of and, optionally, the path to the X509 certificate file that is used to form the certificate-key pair.

#####`certificate_format

Input format of the certificate and the private-key files. The two formats supported by the appliance are: PEM: Privacy Enhanced Mail; DER: Distinguished Encoding.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`fipskey`

Name of the FIPS key that was created inside the Hardware Security Module (HSM) of a FIPS appliance, or a key that was imported into the HSM.

#####`key_filename`

Name of and, optionally, the path to the private-key file that is used to form the certificate-key pair.

#####`linkcert_keyname`

Name of the Certificate Authority certificate-key pair to which to link a certificate-key pair.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`nodomaincheck`

Override the check for matching domain names during a certificate update operation.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`notificationperiod`

Time, in number of days, before certificate expiration, at which to generate an alert that the certificate is about to expire.

#####`notify_when_expires`

Issue an alert when the certificate is about to expire.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`passplain`

Pass phrase used to encrypt the private-key. Required when adding an encrypted private-key in PEM format.

#####`password`

Passphrase that was used to encrypt the private-key.

###Type: netscaler_sslkeyfile

Configures the Imported Keyfile resource.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`source`

The URL specifying the protocol, host, and path, including file name, to the key file to be imported.

###Type: netscaler_sslocspresponder

Configuration for OCSP responder resource.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`name

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`url`

The URL of the OCSP responder.

###Type: netscaler_sslvserver_sslcertkey_binding

Binds the sslvserver and the certkey.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ca`

The CA certificate.

#####`crlcheck`

The state of the CRL check parameter.

Valid options: Mandatory, Optional.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`ocspcheck`

The state of the OCSP check parameter.

Valid options: Mandatory, Optional.

#####`skipcaname`

Indicates whether this particular CA certificate's CA_Name needs to be sent to the SSL client while requesting for client certificate in a SSL handshake.

#####`snicert`

The name of the CertKey. Use this option to bind Certkey(s) that will be used in SNI processing.

###Type: netscaler_user

Configures the system user resource.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`cli_prompt`

String to display at the command-line prompt. Can consist of letters, numbers, hyphen (-), period (.), hash (#), space ( ), at (@), equal (=), colon (:), underscore (_), and the following variables:

* %u - Will be replaced by the user name.
* %h - Will be replaced by the hostname of the NetScaler appliance.
* %t - Will be replaced by the current time in 12-hour format.
* %T - Will be replaced by the current time in 24-hour format.
* %d - Will be replaced by the current date.
* %s - Will be replaced by the state of the NetScaler appliance.

Note: The 63-character limit for the length of the string does not apply to the characters that replace the variables.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`external_authentication`

Whether to use external authentication servers for the system user authentication or not.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'.

#####`idle_time_out`

CLI session inactivity timeout, in seconds. If Restrictedtimeout argument of system parameter is enabled, Timeout can have values in the range [300-86400] seconds. If Restrictedtimeout argument of system parameter is disabled, Timeout can have values in the range [0, 10-100000000] seconds. Default value is 900 seconds.

#####`logging_privilege`

Specifies user logging privileges.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'. Default: DISABLED.

#####`name`

Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters.

#####`password`

Password with which the user logs on. Required for any user account that does not exist on an external authentication server. If you are not using an external authentication server, all user accounts must have a password. If you are using an external authentication server, you must provide a password for local user accounts that do not exist on the authentication server.

### netscaler_vlan

Manages NetScaler VLANS.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`alias_name`

A name for the VLAN. Must begin with a letter, a number, or the underscore symbol, and can consist of from 1 to 31 letters, numbers, and the hyphen (-), period (.) pound (#), space ( ), at sign (@), equals (=), colon (:), and underscore (_) characters.

You should choose a name that helps identify the VLAN. However, you cannot perform any VLAN operation by specifying this name instead of the VLAN ID.

Maximum length = 31.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`ipv6_dynamic_routing`

Enables all IPv6 dynamic routing protocols on this VLAN. Note: For the ENABLED setting to work, you must configure IPv6 dynamic routing protocols from the VTYSH command line.

Valid options: 'yes', 'no', true, false, 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', 'OFF'. Default: DISABLED.

#####`maximum_transmission_unit`

Specifies the maximum transmission unit (MTU), in bytes. The MTU is the largest packet size, excluding 14 bytes of ethernet header and 4 bytes of crc, that can be transmitted and received over this VLAN.

Minimum value = 500
Maximum value = 9216

#####`name`

Uniquely identifies a VLAN. Accepts an integer from 1 to 4094.

### netscaler_vlan_nsip_binding

Manages a binding between a vlan and a NetScaler IP address.

####Parameters

All parameters, except where otherwise noted, are optional. Their default values are determined by your particular NetScaler setup.

#####`ensure`

The basic state that the resource should be in.

Valid values are 'present', 'absent'.

#####`name`
The title of the bind resource, composed of the title of the VLAN and the NetScaler IP address: 'vlan_id/ip_address'.

#####`netmask`

Subnet mask for the network address defined for this VLAN.

#####`td`

Uniquely identifies the traffic domain in which you want to configure the entity. If you do not specify an ID, the entity becomes part of the default traffic domain, which has an ID of 0. Accepts an integer from 0 to 4094.

##Limitations

The netscaler module works with NetScaler 10.5 and later.
