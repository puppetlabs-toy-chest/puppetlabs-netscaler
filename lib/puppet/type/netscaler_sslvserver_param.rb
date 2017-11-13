require_relative('../../puppet/parameter/netscaler_name')
require_relative('../../puppet/property/netscaler_traffic_domain')
require_relative('../../puppet/property/netscaler_truthy')

Puppet::Type.newtype(:netscaler_sslvserver_param) do
  @doc = 'Configuration for SSL virtual server resource. SSL parameters.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)
  desc "This is the binding of sslvserver"

  newproperty(:ssl3) do
    desc "State of SSLv3 protocol support for the SSL Virtual Server."
  end

  newproperty(:sslredirect) do
    desc "State of HTTPS redirects for the SSL virtual server."
  end

end
