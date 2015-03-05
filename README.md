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

The netscaler module enables Puppet configuration of Citrix Netscaler devices through types and REST-based providers.

##Module Description

This module uses REST to manage various aspects of Netscaler load balancers, and acts
as a foundation for building higher level abstractions within Puppet.

The module allows you to manage Netscaler nodes and pool configuration through Puppet.

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

This example is built around the following infrastructure: A server running a Puppet master is connected to the Netscaler device. The Netscaler device contains a management VLAN, a client VLAN which will contain the virtual server, and a server VLAN which will connect to the two web servers the module will be setting up. 

In order to successfully set up your web servers, you must know the following information about your systems:

1. The IP addresses of both of the web servers;
2. The names of the nodes each web server will be on;
3. The ports the web servers are listening on; and
4. The IP address of the virtual server.

####Step One: Classifying your servers

In your site.pp file, enter the below code:

**TODO:Update for Netscaler**
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

Run the following to have the Puppet master apply your classifications and configure the Netscaler device: 

~~~
$ FACTER_url=https:/<USERNAME>:<PASSWORD>@<IP ADDRESS OF BIGIP> puppet device -v
~~~

If you do not run this command, clients will not be able to make requests to the web servers.

At this point, your basic web servers should be up and fielding requests.

###Tips and Tricks

####Basic Usage

Once you've established a basic configuration, you can explore the providers and their allowed options by running `puppet resource <TYPENAME>` for each type. This will provide a starting point for seeing what's already on your Netscaler. If anything failed to set up properly, it will not show up when you run the command.

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
The [above example](#set-up-two-loadbalanced-web-servers) is for setting up a simple configuration of two web servers. However, for anything more complicated, you will want to use the roles and profiles pattern when classifying nodes or devices for Netscaler.

####Custom HTTP monitors
If you have a '/Common/http_monitor (which is available by default), then when you are creating a /Common/custom_http_monitor you can simply use `parent_monitor => '/Common/http'` so that you don't have to duplicate all values.

##Reference

###Public Types
**TODO: Are most parameters optional?**

* [`netscaler_monitor`](#type-netscaler_monitor)
* [`netscaler_server`](#type-netscaler_server)
* [`netscaler_service`](#type-netscaler_service)
* [`netscaler_service_lbmonitor-bind`](#type-netscaler_service_lbmonitor-bind)

###Type: netscaler_monitor

###Type: netscaler_server

###Type: netscaler_service

Manages service on the NetScaler appliance. If the service is domain-based, you must use the `add server`command to create the server entry before creating the service. You must specify the Server parameter**?** in the command `add server X`**TODO:?**
 
####Parameters
 
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

If you set `client_ip` and you do not specify a name for the header, the appliance uses the header name specified for the global `client_ip_header` parameter.  (the cipHeader parameter in the set ns param CLI command or the Client IP Header parameter in the Configure HTTP Parameters dialog box at System > Settings > Change HTTP parameters)**TODO: Whut?**. If the global `client_ip_header` parameter is not specified, the appliance inserts a header with the name "client-ip."

Valid options:**TODO**
 
#####`client_keepalive`
Enables client keep-alive for the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: **TODO**
   
#####`comments`
Provides any necessary or additional information about the object.

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

Valid options: '*' or integers **TODO**
 
#####`protocol`
*Required.* Specifies the protocol in which data is exchanged with the service.

Valid options: **TODO**
 
#####`provider`
Sets the specific backend to use for this `netscaler_service` resource. You will seldom need to specify this, as Puppet will usually discover the appropriate provider for your platform. 

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
Specifies the integer value that uniquely identifies the traffic domain in which you want to configure the entity. If you do not specify an ID, the entity becomes part of the default traffic domain, which has an ID of 0.

Valid options: Integer; minimum = 0 and maximum = 4096
 
#####`use_proxy_port`
Uses the proxy port as the source port when initiating connections with the server. Disabling this parameter means the client-side connection port is used as the source port for the server-side connection. This parameter is available only when the `use_source_ip` parameter is set to 'YES'. **TODO: Set to yes or simply enabled?**

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'. Default: **TODO**
 
#####`use_source_ip`
Uses the client's IP address as the source IP address when initiating a connection to the server. When creating a service, if you do not set this parameter, the service inherits the global Use Source IP setting (available in the enable ns mode and disable ns mode CLI commands, or in the System > Settings > Configure modes > Configure Modes dialog box). However, you can override this setting after you create the service.

Valid options: 'yes', 'no', 'true', 'false', 'enabled', 'disabled', 'ENABLED', 'DISABLED', 'YES', 'NO', 'on', 'off', 'ON', or 'OFF'.

