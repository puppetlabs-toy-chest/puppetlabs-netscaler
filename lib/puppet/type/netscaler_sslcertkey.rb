require_relative('../../puppet/parameter/netscaler_name')
require_relative('../../puppet/property/netscaler_traffic_domain')
require_relative('../../puppet/property/netscaler_truthy')

Puppet::Type.newtype(:netscaler_sslcertkey) do
  @doc = 'Configuration for Imported Certfile resource'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)
  #XXX Validate with the below
  #ensure: change from absent to present failed: Could not set 'present' on ensure: REST failure: HTTP status code 400 detected.  Body of failure is: { "errorcode": 1075, "message": "Invalid name; names must begin with an alphanumeric character or underscore and must contain only alphanumerics, '_', '#', '.', ' ', ':', '@', '=' or '-' [name, hunner's website]", "severity": "ERROR" } at 55:/etc/puppetlabs/puppet/environments/produc

  newproperty(:certificate_filename) do
    desc "Name of and, optionally, path to the X509 certificate file that is used to form the certificate-key pair. If you use the netscaler_file resource you will need a full path eg /nsconfig/server.cert. This may throw an error the first time you apply the manifest"
  end

  newproperty(:key_filename) do
    desc "Name of and, optionally, path to the private-key file that is used to form the certificate-key pair. If you use the netscaler_file resource you will need a full path eg /nsconfig/server.key. This may throw an error the first time you apply the manifest"
  end

  newproperty(:password, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Passphrase that was used to encrypt the private-key.", "true", "false")
  end

  newproperty(:fipskey) do
    desc "Name of the FIPS key that was created inside the Hardware Security Module (HSM) of a FIPS appliance, or a key that was imported into the HSM."
  end

  newproperty(:certificate_format) do
    desc "Input format of the certificate and the private-key files. The two formats supported by the appliance are: PEM - Privacy Enhanced Mail DER - Distinguished Encoding"
    validate do |value|
      if ! [
        :PEM,
        :DER,
      ].include? value.to_sym
        fail ArgumentError, "Valid options: PEM, DER"
      end
    end
  end

  newproperty(:passplain) do
    desc "Pass phrase used to encrypt the private-key. Required when adding an encrypted private-key in PEM format."
  end

  newproperty(:notify_when_expires, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Issue an alert when the certificate is about to expire.", "ENABLED", "DISABLED")
  end

  newproperty(:notificationperiod) do
    desc "Time, in number of days, before certificate expiration, at which to generate an alert that the certificate is about to expire."
  end

  newproperty(:bundle, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Parse the certificate chain as a single file after linking the server certificate to its issuer's certificate within the file.", "YES", "NO")
  end

  newproperty(:linkcert_keyname) do
    desc "Name of the Certificate Authority certificate-key pair to which to link a certificate-key pair."
  end

  newproperty(:nodomaincheck, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Override the check for matching domain names during a certificate update operation.", "true", "false")
  end
end
