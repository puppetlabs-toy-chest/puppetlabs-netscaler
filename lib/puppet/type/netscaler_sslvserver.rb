require_relative('../../puppet/parameter/netscaler_name')
require_relative('../../puppet/property/netscaler_truthy')
require_relative('../../puppet/property/netscaler_traffic_domain')

Puppet::Type.newtype(:netscaler_sslvserver) do
  @doc = 'Sets advanced SSL configuration for an SSL virtual server.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)

  newproperty(:clear_text_port) do
    desc "Port on which clear-text data is sent by the appliance to the server. Do not specify this parameter for SSL offloading with end-to-end encryption.

Default value: 0"
  end

  newproperty(:dh, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("State of Diffie-Hellman (DH) key exchange.

Possible values: ENABLED, DISABLED

Default value: DISABLED", ["ENABLED", "DISABLED"])

    munge(&:upcase)
  end

  newproperty(:dh_file) do
    desc "Name of and, optionally, path to the DH parameter file, in PEM format, to be installed. /nsconfig/ssl/ is the default path."
  end

  newproperty(:dh_count) do
    desc "Number of interactions, between the client and the NetScaler appliance, after which the DH private-public pair is regenerated. A value of zero (0) specifies infinite use (no refresh).

Minimum value: 0

Maximum value: 65534"
  end

  newproperty(:dh_key_exp_size_limit, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("This option enables the use of NIST recommended (NIST Special Publication 800-56A) bit size for private-key size. For example, for DH params of size 2048bit, the private-key size recommended is 224bits. This is rounded-up to 256bits.

Possible values: ENABLED, DISABLED

Default value: DISABLED", ["ENABLED", "DISABLED"])

    munge(&:upcase)
  end

  newproperty(:ersa, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("State of Ephemeral RSA (eRSA) key exchange. Ephemeral RSA allows clients that support only export ciphers to communicate with the secure server even if the server certificate does not support export clients. The ephemeral RSA key is automatically generated when you bind an export cipher to an SSL or TCP-based SSL virtual server or service. When you remove the export cipher, the eRSA key is not deleted. It is reused at a later date when another export cipher is bound to an SSL or TCP-based SSL virtual server or service. The eRSA key is deleted when the appliance restarts.

Possible values: ENABLED, DISABLED

Default value: ENABLED", ["ENABLED", "DISABLED"])

    munge(&:upcase)
  end

  newproperty(:ersa_count) do
    desc "Refresh count for regeneration of the RSA public-key and private-key pair. Zero (0) specifies infinite usage (no refresh).

Minimum value: 0

Maximum value: 65534"
  end

  newproperty(:sess_reuse, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("State of session reuse. Establishing the initial handshake requires CPU-intensive public key encryption operations. With the ENABLED setting, session key exchange is avoided for session resumption requests received from the client.

Possible values: ENABLED, DISABLED

Default value: ENABLED", ["ENABLED", "DISABLED"])

    munge(&:upcase)
  end

  newproperty(:sess_timeout) do
    desc "Time, in seconds, for which to keep the session active. Any session resumption request received after the timeout period will require a fresh SSL handshake and establishment of a new SSL session.

Default value: 120

Minimum value: 0

Maximum value: 4294967294"
  end

  newproperty(:cipher_redirect, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("State of Cipher Redirect. If cipher redirect is enabled, you can configure an SSL virtual server or service to display meaningful error messages if the SSL handshake fails because of a cipher mismatch between the virtual server or service and the client.

Possible values: ENABLED, DISABLED

Default value: DISABLED", ["ENABLED", "DISABLED"])

    munge(&:upcase)
  end

  newproperty(:cipher_url) do
    desc "The redirect URL to be used with the Cipher Redirect feature."
  end

  newproperty(:sslv2_redirect, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("State of SSLv2 Redirect. If SSLv2 redirect is enabled, you can configure an SSL virtual server or service to display meaningful error messages if the SSL handshake fails because of a protocol version mismatch between the virtual server or service and the client.

Possible values: ENABLED, DISABLED

Default value: DISABLED", ["ENABLED", "DISABLED"])

    munge(&:upcase)
  end

  newproperty(:sslv2_url) do
    desc "URL of the page to which to redirect the client in case of a protocol version mismatch. Typically, this page has a clear explanation of the error or an alternative location that the transaction can continue from."
  end

  newproperty(:client_auth, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("State of client authentication. If client authentication is enabled, the virtual server terminates the SSL handshake if the SSL client does not provide a valid certificate.

Possible values: ENABLED, DISABLED

Default value: DISABLED", ["ENABLED", "DISABLED"])

    munge(&:upcase)
  end

  newproperty(:client_cert) do
    desc "Type of client authentication. If this parameter is set to MANDATORY, the appliance terminates the SSL handshake if the SSL client does not provide a valid certificate. With the OPTIONAL setting, the appliance requests a certificate from the SSL clients but proceeds with the SSL transaction even if the client presents an invalid certificate.

Caution: Define proper access control policies before changing this setting to Optional.

Possible values: Mandatory, Optional"

    validate do |value|
      if ! [:MANDATORY, :OPTIONAL].any?{ |s| s.to_s.eql? value }
        fail ArgumentError, "Valid options: MANDATORY, OPTIONAL"
      end
    end

    munge(&:upcase)
  end

  newproperty(:ssl_redirect, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("State of HTTPS redirects for the SSL virtual server. 

For an SSL session, if the client browser receives a redirect message, the browser tries to connect to the new location. However, the secure SSL session breaks if the object has moved from a secure site (https://) to an unsecure site (http://). Typically, a warning message appears on the screen, prompting the user to continue or disconnect.

If SSL Redirect is ENABLED, the redirect message is automatically converted from http:// to https:// and the SSL session does not break.

Possible values: ENABLED, DISABLED

Default value: DISABLED", ["ENABLED", "DISABLED"])

    munge(&:upcase)
  end

  newproperty(:redirect_port_rewrite, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("State of the port rewrite while performing HTTPS redirect. If this parameter is ENABLED and the URL from the server does not contain the standard port, the port is rewritten to the standard.

Possible values: ENABLED, DISABLED

Default value: DISABLED", ["ENABLED", "DISABLED"])

    munge(&:upcase)
  end

  newproperty(:non_fips_ciphers, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("State of usage of non-FIPS approved ciphers. Valid only for an SSL service bound with a FIPS key and certificate.

Possible values: ENABLED, DISABLED

Default value: DISABLED", ["ENABLED", "DISABLED"])

    munge(&:upcase)
  end

  newproperty(:ssl2, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("State of SSLv2 protocol support for the SSL Virtual Server.

Possible values: ENABLED, DISABLED

Default value: DISABLED", ["ENABLED", "DISABLED"])

    munge(&:upcase)
  end

  newproperty(:ssl3, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("State of SSLv3 protocol support for the SSL Virtual Server.

Possible values: ENABLED, DISABLED

Default value: ENABLED", ["ENABLED", "DISABLED"])

    munge(&:upcase)
  end

  newproperty(:tls1, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("State of TLSv1.0 protocol support for the SSL Virtual Server.

Possible values: ENABLED, DISABLED

Default value: ENABLED", ["ENABLED", "DISABLED"])

    munge(&:upcase)
  end

  newproperty(:tls11, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("State of TLSv1.1 protocol support for the SSL Virtual Server. TLSv1.1 protocol is supported only on the MPX appliance. Support is not available on a FIPS appliance or on a NetScaler VPX virtual appliance. On an SDX appliance, TLSv1.1 protocol is supported only if an SSL chip is assigned to the instance.

Possible values: ENABLED, DISABLED

Default value: ENABLED", ["ENABLED", "DISABLED"])

    munge(&:upcase)
  end

  newproperty(:tls12, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("State of TLSv1.2 protocol support for the SSL Virtual Server. TLSv1.2 protocol is supported only on the MPX appliance. Support is not available on a FIPS appliance or on a NetScaler VPX virtual appliance. On an SDX appliance, TLSv1.2 protocol is supported only if an SSL chip is assigned to the instance.

Possible values: ENABLED, DISABLED

Default value: ENABLED", ["ENABLED", "DISABLED"])

    munge(&:upcase)
  end

  newproperty(:sni_enable, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("State of the Server Name Indication (SNI) feature on the virtual server and service-based offload. SNI helps to enable SSL encryption on multiple domains on a single virtual server or service if the domains are controlled by the same organization and share the same second-level domain name. For example, *.sports.net can be used to secure domains such as login.sports.net and help.sports.net.

Possible values: ENABLED, DISABLED

Default value: DISABLED", ["ENABLED", "DISABLED"])

    munge(&:upcase)
  end

  newproperty(:push_enc_trigger) do
    desc "Trigger encryption on the basis of the PUSH flag value. Available settings function as follows:

* ALWAYS - Any PUSH packet triggers encryption.

* IGNORE - Ignore PUSH packet for triggering encryption.

* MERGE - For a consecutive sequence of PUSH packets, the last PUSH packet triggers encryption.

* TIMER - PUSH packet triggering encryption is delayed by the time defined in the set ssl parameter command or in the Change Advanced SSL Settings dialog box.

Possible values: Always, Merge, Ignore, Timer"

    validate do |value|
      if ! [:ALWAYS, :MERGE, :IGNORE, :TIMER].any?{ |s| s.to_s.eql? value }
        fail ArgumentError, "Valid options: ALWAYS, MERGE, IGNORE, TIMER"
      end
    end

    munge(&:upcase)
  end

  newproperty(:send_close_notify, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Enable sending SSL Close-Notify at the end of a transaction

Possible values: YES, NO

Default value: YES", ["YES", "NO"])

    munge(&:upcase)
  end

  newproperty(:dtls_profile_name) do
    desc "Name of the DTLS profile whose settings are to be applied to the virtual server."
  end

  newproperty(:ssl_profile) do
    desc "Name of the SSL profile that contains SSL settings for the virtual server."
  end

end
