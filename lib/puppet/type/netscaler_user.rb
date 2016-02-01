require_relative('../../puppet/parameter/netscaler_name')
require_relative('../../puppet/property/netscaler_traffic_domain')
require_relative('../../puppet/property/netscaler_truthy')

Puppet::Type.newtype(:netscaler_user) do
  @doc = 'Configuration for system user resource.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)
  #XXX Validate with the below
  #ensure: change from absent to present failed: Could not set 'present' on ensure: REST failure: HTTP status code 400 detected.  Body of failure is: { "errorcode": 1075, "message": "Invalid name; names must begin with an alphanumeric character or underscore and must contain only alphanumerics, '_', '#', '.', ' ', ':', '@', '=' or '-' [name, hunner's website]", "severity": "ERROR" } at 55:/etc/puppetlabs/puppet/environments/produc

  newparam(:password) do
    desc "Password with which the user logs on. Required for any user account that does not exist on an external authentication server. This is only set on creation, this is due to the password being returned as a hash."
  end

  newproperty(:external_authentication, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Whether to use external authentication servers for the system user authentication or not.", "ENABLED", "DISABLED")
  end

  newproperty(:cli_prompt) do
    desc "String to display at the command-line prompt. Can consist of letters, numbers, hyphen (-), period (.), hash (#), space ( ), at (@), equal (=), colon (:), underscore (_), and the following variables: * %u - Will be replaced by the user name. * %h - Will be replaced by the hostname of the NetScaler appliance. * %t - Will be replaced by the current time in 12-hour format. * %T - Will be replaced by the current time in 24-hour format. * %d - Will be replaced by the current date. * %s - Will be replaced by the state of the NetScaler appliance. Note: The 63-character limit for the length of the string does not apply to the characters that replace the variables."
  end

  newproperty(:idle_time_out) do
    desc "CLI session inactivity timeout, in seconds. If Restrictedtimeout argument of system parameter is enabled, Timeout can have values in the range [300-86400] seconds. If Restrictedtimeout argument of system parameter is disabled, Timeout can have values in the range [0, 10-100000000] seconds. Default value is 900 seconds."
  end

  newproperty(:logging_privilege, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Users logging privilege. Default value: DISABLED", "ENABLED", "DISABLED")
  end
end
