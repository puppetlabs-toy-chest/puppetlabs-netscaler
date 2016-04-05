require_relative('../../puppet/parameter/netscaler_name')
require_relative('../../puppet/property/netscaler_traffic_domain')
require_relative('../../puppet/property/netscaler_truthy')

Puppet::Type.newtype(:netscaler_sslvserver_sslcertkey_binding) do
  @doc = 'Configuration for SSL virtual server resource - binding with certkey.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)
  desc "This is the binding of sslvserver/certkey"
  #XXX Validate with the below
  #ensure: change from absent to present failed: Could not set 'present' on ensure: REST failure: HTTP status code 400 detected.  Body of failure is: { "errorcode": 1075, "message": "Invalid name; names must begin with an alphanumeric character or underscore and must contain only alphanumerics, '_', '#', '.', ' ', ':', '@', '=' or '-' [name, hunner's website]", "severity": "ERROR" } at 55:/etc/puppetlabs/puppet/environments/produc

  newproperty(:crlcheck) do
    desc "The state of the CRL check parameter. (Mandatory/Optional).
Possible values = Mandatory, Optional"
  end

  newproperty(:ca) do
    desc "CA certificate."
  end

  newproperty(:snicert) do
    desc "The name of the CertKey. Use this option to bind Certkey(s) which will be used in SNI processing."
  end

  newproperty(:skipcaname) do
    desc "The flag is used to indicate whether this particular CA certificate's CA_Name needs to be sent to the SSL client while requesting for client certificate in a SSL handshake."
  end

  newproperty(:ocspcheck) do
    desc "The state of the OCSP check parameter. (Mandatory/Optional).
Possible values = Mandatory, Optional"
  end
end
