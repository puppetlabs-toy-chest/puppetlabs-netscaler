require 'puppet/parameter/netscaler_name'
require 'puppet/property/netscaler_traffic_domain'
require 'puppet/property/netscaler_truthy'

Puppet::Type.newtype(:netscaler_sslkeyfile) do
  @doc = 'Configuration for Imported Keyfile resource.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)
  #XXX Validat with the below
  #ensure: change from absent to present failed: Could not set 'present' on ensure: REST failure: HTTP status code 400 detected.  Body of failure is: { "errorcode": 1075, "message": "Invalid name; names must begin with an alphanumeric character or underscore and must contain only alphanumerics, '_', '#', '.', ' ', ':', '@', '=' or '-' [name, hunner's website]", "severity": "ERROR" } at 55:/etc/puppetlabs/puppet/environments/produc

  newproperty(:source) do
    desc "URL specifying the protocol, host, and path, including file name, to the key file to be imported."
  end

end
