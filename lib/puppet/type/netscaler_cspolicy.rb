require 'puppet/parameter/netscaler_name'
require 'puppet/property/netscaler_truthy'

Puppet::Type.newtype(:netscaler_cspolicy) do
  @doc = 'Manage basic netscaler cs policy objects.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)
  #XXX Validat with the below
  #ensure: change from absent to present failed: Could not set 'present' on ensure: REST failure: HTTP status code 400 detected.  Body of failure is: { "errorcode": 1075, "message": "Invalid name; names must begin with an alphanumeric character or underscore and must contain only alphanumerics, '_', '#', '.', ' ', ':', '@', '=' or '-' [name, hunner's website]", "severity": "ERROR" } at 55:/etc/puppetlabs/puppet/environments/produc

  #requires the creation of an "cs action" or NOOP, RESET, DROP
  newproperty(:action) do
    desc "Name of the cs action to perform if the request matches this cs policy."
  end

  #requires the creation of an "Audit message action"
  newproperty(:log_action) do
    desc "Name of the messagelog action to use for requests that match this policy."
  end

  newproperty(:domain) do 
    desc "The domain name. The string value can range to 63 characters."
  end

  newproperty(:url) do
    desc "URL string that is matched with the URL of a request. Can contain a wildcard character. Specify the string value in the following format: [[prefix] [*]] [.suffix]."
  end

  newproperty(:expression) do
    desc "Expression, or name of a named expression, against which traffic is evaluated. Written in the classic or default syntax."
  end

  autorequire (:netscaler_csaction) do
    self[:action]
  end
end
