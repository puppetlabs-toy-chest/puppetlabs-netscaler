require 'puppet/parameter/netscaler_name'
require 'puppet/property/netscaler_truthy'
require 'puppet/property/netscaler_traffic_domain'

Puppet::Type.newtype(:netscaler_sslcert) do
  @doc = 'Configuration for cerificate resource.'

  apply_to_device
  ensurable

  newparam(:name, :namevar => true) do
    desc "Name of the responder policy."
  end 
 
  newproperty(:certfile) do
    desc "Name for and, optionally, path to the generated certificate file. /nsconfig/ssl/ is the default path."
  end

  newproperty(:reqfile) do
    desc "Name for and, optionally, path to the certificate-signing request (CSR). /nsconfig/ssl/ is the default path."
  end

  newproperty(:certtype) do
    desc "Type of certificate to generate"
    validate do |value|
      if ! [
        :ROOT_CERT, 
        :INTM_CERT,
        :CLNT_CERT,
        :SRVR_CERT,
      ].include? value.to_sym
        fail ArgumentError, "Valid options: ROOT_CERT, INTM_CERT, CLNT_CERT, SRVR_CERT" 
      end
    end
  end
  
  newproperty(:keyfile) do
    desc "Name for and, optionally, path to the private key."
  end

  newproperty(:keyform) do
    desc "Format in which the key is stored on the appliance."
    validate do |value|
      if ! [
        :PEM, 
        :DER,
      ].include? value.to_sym
        fail ArgumentError, "Valid options: PEM, DER" 
      end
    end
  end
 
  newproperty(:pempassphrase) do
    desc ""
  end
 
  newproperty(:days) do
    desc "Number of days for which the certificate will be valid, beginning with the time and day (system time) of creation."
  end

  newproperty(:certform) do
    desc "Format in which the certificate is stored on the appliance."
    validate do |value|
      if ! [
        :PEM, 
        :DER,
      ].include? value.to_sym
        fail ArgumentError, "Valid options: PEM, DER" 
      end
    end
  end
 
  newproperty(:cacert) do
    desc "Name of the CA certificate file that issues and signs the Intermediate-CA certificate or the end-user client and server certificates."
  end

  newproperty(:cacertform) do
    desc "Format in which the CA certificate is stored on the appliance."
    validate do |value|
      if ! [
        :PEM, 
        :DER,
      ].include? value.to_sym
        fail ArgumentError, "Valid options: PEM, DER" 
      end
    end
  end
 
  newproperty(:cakey) do
    desc "Private key, associated with the CA certificate that is used to sign the Intermediate-CA certificate or the end-user client and server certificate."
  end

  newproperty(:cakeyform) do
    desc "Format for the CA certificate."
    validate do |value|
      if ! [
        :PEM, 
        :DER,
      ].include? value.to_sym
        fail ArgumentError, "Valid options: PEM, DER" 
      end
    end
  end

  newproperty(:caserial) do
    desc "Serial number file maintained for the CA certificate."
  end
 
end
