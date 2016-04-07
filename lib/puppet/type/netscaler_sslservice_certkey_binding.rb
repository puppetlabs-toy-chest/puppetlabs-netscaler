require_relative('../../puppet/parameter/netscaler_name')
require_relative('../../puppet/property/netscaler_truthy')
require_relative('../../puppet/property/netscaler_traffic_domain')

Puppet::Type.newtype(:netscaler_sslservice_certkey_binding) do
  @doc = 'Binds an SSL certificate-key pair or an SSL policy to a certkey.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)

  newproperty(:ca) do
    desc "Name of the CA certificate that issues and signs the intermediate-CA certificate or the end-user client or server certificate."
  end

  newproperty(:crl_check) do
    desc "Rule to use for the CRL corresponding to the CA certificate during client authentication. Available settings function as follows:

* MANDATORY - Deny SSL clients if the CRL is missing or expired, or the Next Update date is in the past, or the CRL is incomplete.

* OPTIONAL - Allow SSL clients if the CRL is missing or expired, or the Next Update date is in the past, or the CRL is incomplete, but deny if the client certificate is revoked in the CRL.

Possible values: Mandatory, Optional"

    validate do |value|
      if ! [:MANDATORY, :OPTIONAL].any?{ |s| s.to_s.eql? value }
        fail ArgumentError, "Valid options: MANDATORY, OPTIONAL"
      end
    end

    munge(&:upcase)
  end

  newproperty(:skip_ca_name) do
    desc "The flag is used to indicate whether this particular CA certificate's CA_Name needs to be sent to the SSL client while requesting for client certificate in a SSL handshake"
  end

  newproperty(:sni_cert) do
    desc "Name of the certificate-key pair to bind for use in SNI processing."
  end

  newproperty(:ocsp_check) do
    desc "Rule to use for the OCSP responder associated with the CA certificate during client authentication. If MANDATORY is specified, deny all SSL clients if the OCSP check fails because of connectivity issues with the remote OCSP server, or any other reason that prevents the OCSP check. With the OPTIONAL setting, allow SSL clients even if the OCSP check fails except when the client certificate is revoked.

Possible values: Mandatory, Optional"

    validate do |value|
      if ! [:MANDATORY, :OPTIONAL].any?{ |s| s.to_s.eql? value }
        fail ArgumentError, "Valid options: MANDATORY, OPTIONAL"
      end
    end

    munge(&:upcase)
  end

  autorequire(:netscaler_sslservice) do
    self[:name].split('/')[0]
  end

  autorequire(:netscaler_sslcertkey) do
    self[:name].split('/')[1]
  end
end
