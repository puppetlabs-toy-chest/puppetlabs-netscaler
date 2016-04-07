require_relative('../../puppet/parameter/netscaler_name')
require_relative('../../puppet/property/netscaler_truthy')
require_relative('../../puppet/property/netscaler_traffic_domain')

Puppet::Type.newtype(:netscaler_sslservice_cipher_binding) do
  @doc = 'Binds an SSL certificate-key pair or an SSL policy to a cipher.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)

  autorequire(:netscaler_sslservice) do
    self[:name].split('/')[0]
  end
end
