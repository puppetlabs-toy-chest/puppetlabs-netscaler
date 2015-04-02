require 'puppet/parameter/netscaler_name'
require 'puppet/property/netscaler_traffic_domain'
require 'puppet/property/netscaler_truthy'

Puppet::Type.newtype(:netscaler_group_user_bind) do
  @doc = 'Binding object showing the systemuser that can be bound to systemgroup.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)
    desc "Group and user binding. In the following format: 'group/user' e.g.: 'testers/joe'"
  #XXX Validate with the below
  #ensure: change from absent to present failed: Could not set 'present' on ensure: REST failure: HTTP status code 400 detected.  Body of failure is: { "errorcode": 1075, "message": "Invalid name; names must begin with an alphanumeric character or underscore and must contain only alphanumerics, '_', '#', '.', ' ', ':', '@', '=' or '-' [name, hunner's website]", "severity": "ERROR" } at 55:/etc/puppetlabs/puppet/environments/produc
end
