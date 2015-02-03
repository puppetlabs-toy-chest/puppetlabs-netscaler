require 'puppet/parameter/netscaler_name'
require 'puppet/property/netscaler_truthy'
require 'puppet/property/netscaler_traffic_domain'

Puppet::Type.newtype(:netscaler_responderpolicy) do
  @doc = 'Manage basic netscaler responder policy objects.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)
  #XXX Validat with the below
  #ensure: change from absent to present failed: Could not set 'present' on ensure: REST failure: HTTP status code 400 detected.  Body of failure is: { "errorcode": 1075, "message": "Invalid name; names must begin with an alphanumeric character or underscore and must contain only alphanumerics, '_', '#', '.', ' ', ':', '@', '=' or '-' [name, hunner's website]", "severity": "ERROR" } at 55:/etc/puppetlabs/puppet/environments/produc

  newproperty(:rule) do
    desc "Default syntax expression that the policy uses to determine whether to respond to the specified request."
  end

  #requires the creation of an "Responder action" or NOOP, RESET, DROP
  newproperty(:action) do
    desc "Name of the responder action to perform if the request matches this responder policy."
  end

  newproperty(:undefaction) do 
    desc "Action to perform if the result of policy evaluation is undefined"
  end

  newproperty(:comments) do
    desc "Any type of information about this responder policy."
  end

  #requires the creation of an "Audit message action"
  newproperty(:logaction) do
    desc "Name of the messagelog action to use for requests that match this policy."
  end

  #requires the creation of an "AppFlow action", and subsequently an "Appflow collector"
  newproperty(:appflowaction) do
    desc "AppFlow action to invoke for requests that match this policy."
  end
end
