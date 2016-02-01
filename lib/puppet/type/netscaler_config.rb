require_relative('../../puppet/parameter/netscaler_name')
require_relative('../../puppet/property/netscaler_truthy')

Puppet::Type.newtype(:netscaler_config) do
  @doc = 'Configuration for system config resource.'

  apply_to_device
  ensurable

  newparam(:name, :namevar => true) do  
    desc "default"
  end

  newproperty(:ipaddress) do  
    desc "IP address of the NetScaler appliance. Commonly referred to as NSIP address. This parameter is mandatory to bring up the appliance."
  end

  newproperty(:netmask) do
    desc "Netmask corresponding to the IP address. This parameter is mandatory to bring up the appliance."
  end

  newproperty(:nsvlan) do 
    desc "(NSVLAN) for the subnet on which the IP address resides.
Minimum value = 2
Maximum value = 4094"
  end

  newproperty(:ifnum) do
    desc "Interfaces of the appliances that must be bound to the NSVLAN.
Minimum length = 1"
  end

  newproperty(:tagged) do
    desc "Specifies that the interfaces will be added as 802.1q tagged interfaces. Packets sent on these interface on this VLAN will have an additional 4-byte 802.1q tag which identifies the VLAN. To use 802.1q tagging, the switch connected to the appliance's interfaces must also be configured for tagging."
  end

  newproperty(:httpport) do
    desc "The HTTP ports on the Web server. This allows the system to perform connection off-load for any client request that has a destination port matching one of these configured ports.
Minimum value = 1"
  end

  newproperty(:maxconn) do
    desc "The maximum number of connections that will be made from the system to the web server(s) attached to it. The value entered here is applied globally to all attached servers.
Minimum value = 0
Maximum value = 4294967294"
  end

  newproperty(:maxreq) do
    desc "The maximum number of requests that the system can pass on a particular connection between the system and a server attached to it. Setting this value to 0 allows an unlimited number of requests to be passed.
Minimum value = 0
Maximum value = 65535"
  end
  newproperty(:cip) do
    desc "The option to control (enable or disable) the insertion of the actual client IP address into the HTTP header request passed from the client to one, some, or all servers attached to the system. The passed address can then be accessed through a minor modification to the server. l  If cipHeader is specified, it will be used as the client IP header. l If it is not specified, then the value that has been set by the set ns config CLI command will be used as the client IP header.
Possible values = ENABLED, DISABLED"
  end

  newproperty(:cipheader) do
    desc "The text that will be used as the client IP header.
Minimum length = 1"
  end

  newproperty(:cookieversion) do
    desc "The version of the cookie inserted by system.
Possible values = 0, 1"
  end

  newproperty(:securecookie) do
    desc "enable/disable secure flag for persistence cookie.
Default value: ENABLED
Possible values = ENABLED, DISABLED"
  end

  newproperty(:pmtumin) do
    desc "The minimum Path MTU.
Default value: 576
Minimum value = 168
Maximum value = 1500"
  end

  newproperty(:pmtutimeout) do
    desc "The timeout value in minutes.
Default value: 10
Minimum value = 1
Maximum value = 1440"
  end

  newproperty(:ftpportrange) do
    desc "Port range configured for FTP services.
Minimum length = 1024
Maximum length = 64000"
  end

  newproperty(:crportrange) do
    desc "Port range for cache redirection services.
Minimum length = 1
Maximum length = 65535"
  end

  newproperty(:timezone) do
    desc "Name of the timezone."
  end

  newproperty(:grantquotamaxclient) do
    desc "The percentage of shared quota to be granted at a time for maxClient.
Default value: 10
Minimum value = 0
Maximum value = 100"
  end

  newproperty(:exclusivequotamaxclient) do
    desc "The percentage of maxClient to be given to PEs.
Default value: 80
Minimum value = 0
Maximum value = 100"
  end

  newproperty(:grantquotaspillover) do
    desc "The percentage of shared quota to be granted at a time for spillover.
Default value: 10
Minimum value = 0
Maximum value = 100"
  end

  newproperty(:exclusivequotaspillover) do
    desc "The percentage of max limit to be given to PEs.
Default value: 80
Minimum value = 0
Maximum value = 100"
  end

  newproperty(:nwfwmode) do
    desc "Network Firewall mode to be used. NOFIREWALL - No Network firewall setting BASIC - DENY-ALL behavior and DENY-ALL AT BOOTUP EXTENDED - NS_NWFWMODE_BASIC + drop IP fragments + TCP and ACL logging + packet drop on closed port EXTENDEDPLUS - NS_NWFWMODE_EXTENDED + block traffic on 3008-3011 + drop non-session packets FULL - NS_NWFWMODE_EXTENDEDPLUS + drop non-ip packets.
Default value: NOFIREWALL
Possible values = NOFIREWALL, BASIC, EXTENDED, EXTENDEDPLUS, FULL:"
  end
end
