require_relative('../../puppet/parameter/netscaler_name')
require_relative('../../puppet/property/netscaler_truthy')
require_relative('../../puppet/property/netscaler_traffic_domain')

Puppet::Type.newtype(:netscaler_sslservice) do
	@doc = 'Manage SSL Service on the NetScaler appliance.'

	apply_to_device
	ensurable

	newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)

	newproperty(:servicename) do
		desc "Name of the SSL service."
	end

	newproperty(:dh) do
		desc "State of Diffie-Hellman (DH) key exchange. This parameter is not applicable when configuring a backend service.

Possible values: ENABLED, DISABLED

Default value: DISABLED"

		validate do |value|
			if ! [:"POSSIBLE VALUES: ENABLED", :DISABLED].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: ENABLED, DISABLED"
			end
		end

		munge(&:upcase)
	end

	newproperty(:dh_file) do
		desc "Name for and, optionally, path to the PEM-format DH parameter file to be installed. /nsconfig/ssl/ is the default path. This parameter is not applicable when configuring a backend service."
	end

	newproperty(:dh_count) do
		desc "Number of interactions, between the client and the NetScaler appliance, after which the DH private-public pair is regenerated. A value of zero (0) specifies infinite use (no refresh). This parameter is not applicable when configuring a backend service.

Minimum value: 0

Maximum value: 65534"
	end

	newproperty(:dh_keyexpsizelimit) do
		desc "This option enables the use of NIST recommended (NIST Special Publication 800-56A) bit size for private-key size. For example, for DH params of size 2048bit, the private-key size recommended is 224bits. This is rounded-up to 256bits.

Possible values: ENABLED, DISABLED

Default value: DISABLED"

		validate do |value|
			if ! [:"POSSIBLE VALUES: ENABLED", :DISABLED].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: ENABLED, DISABLED"
			end
		end

		munge(&:upcase)
	end

	newproperty(:ersa) do
		desc "State of Ephemeral RSA (eRSA) key exchange. Ephemeral RSA allows clients that support only export ciphers to communicate with the secure server even if the server certificate does not support export clients. The ephemeral RSA key is automatically generated when you bind an export cipher to an SSL or TCP-based SSL virtual server or service. When you remove the export cipher, the eRSA key is not deleted. It is reused at a later date when another export cipher is bound to an SSL or TCP-based SSL virtual server or service. The eRSA key is deleted when the appliance restarts.

This parameter is not applicable when configuring a backend service.

Possible values: ENABLED, DISABLED

Default value: DISABLED"

		validate do |value|
			if ! [:"POSSIBLE VALUES: ENABLED", :DISABLED].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: ENABLED, DISABLED"
			end
		end

		munge(&:upcase)
	end

	newproperty(:ersacount) do
		desc "Refresh count for regeneration of RSA public-key and private-key pair. Zero (0) specifies infinite usage (no refresh).

This parameter is not applicable when configuring a backend service.

Minimum value: 0

Maximum value: 65534"
	end

	newproperty(:sessreuse) do
		desc "State of session reuse. Establishing the initial handshake requires CPU-intensive public key encryption operations. With the ENABLED setting, session key exchange is avoided for session resumption requests received from the client.

Possible values: ENABLED, DISABLED

Default value: ENABLED"

		validate do |value|
			if ! [:"POSSIBLE VALUES: ENABLED", :DISABLED].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: ENABLED, DISABLED"
			end
		end

		munge(&:upcase)
	end

	newproperty(:sesstimeout) do
		desc "Time, in seconds, for which to keep the session active. Any session resumption request received after the timeout period will require a fresh SSL handshake and establishment of a new SSL session.

Default value: 300

Minimum value: 0

Maximum value: 4294967294"
	end

	newproperty(:cipherredirect) do
		desc "State of Cipher Redirect. If this parameter is set to ENABLED, you can configure an SSL virtual server or service to display meaningful error messages if the SSL handshake fails because of a cipher mismatch between the virtual server or service and the client.

This parameter is not applicable when configuring a backend service.

Possible values: ENABLED, DISABLED

Default value: DISABLED"

		validate do |value|
			if ! [:"POSSIBLE VALUES: ENABLED", :DISABLED].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: ENABLED, DISABLED"
			end
		end

		munge(&:upcase)
	end

	newproperty(:cipherurl) do
		desc "URL of the page to which to redirect the client in case of a cipher mismatch. Typically, this page has a clear explanation of the error or an alternative location that the transaction can continue from.

This parameter is not applicable when configuring a backend service."
	end

	newproperty(:sslv2redirect) do
		desc "State of SSLv2 Redirect. If this parameter is set to ENABLED, you can configure an SSL virtual server or service to display meaningful error messages if the SSL handshake fails because of a protocol version mismatch between the virtual server or service and the client.

This parameter is not applicable when configuring a backend service.

Possible values: ENABLED, DISABLED

Default value: DISABLED"

		validate do |value|
			if ! [:"POSSIBLE VALUES: ENABLED", :DISABLED].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: ENABLED, DISABLED"
			end
		end

		munge(&:upcase)
	end

	newproperty(:sslv2url) do
		desc "URL of the page to which to redirect the client in case of a protocol version mismatch. Typically, this page has a clear explanation of the error or an alternative location that the transaction can continue from.

This parameter is not applicable when configuring a backend service."
	end

	newproperty(:clientauth) do
		desc "State of client authentication. In service-based SSL offload, the service terminates the SSL handshake if the SSL client does not provide a valid certificate.

This parameter is not applicable when configuring a backend service.

Possible values: ENABLED, DISABLED

Default value: DISABLED"

		validate do |value|
			if ! [:"POSSIBLE VALUES: ENABLED", :DISABLED].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: ENABLED, DISABLED"
			end
		end

		munge(&:upcase)
	end

	newproperty(:clientcert) do
		desc "Type of client authentication. If this parameter is set to MANDATORY, the appliance terminates the SSL handshake if the SSL client does not provide a valid certificate. With the OPTIONAL setting, the appliance requests a certificate from the SSL clients but proceeds with the SSL transaction even if the client presents an invalid certificate.

This parameter is not applicable when configuring a backend SSL service.

Caution: Define proper access control policies before changing this setting to Optional.

Possible values: Mandatory, Optional"

		validate do |value|
			if ! [:"POSSIBLE VALUES: MANDATORY", :OPTIONAL].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: MANDATORY, OPTIONAL"
			end
		end

		munge(&:upcase)
	end

	newproperty(:sslredirect) do
		desc "State of HTTPS redirects for the SSL service.

For an SSL session, if the client browser receives a redirect message, the browser tries to connect to the new location. However, the secure SSL session breaks if the object has moved from a secure site (https://) to an unsecure site (http://). Typically, a warning message appears on the screen, prompting the user to continue or disconnect.

If SSL Redirect is ENABLED, the redirect message is automatically converted from http:// to https:// and the SSL session does not break.

This parameter is not applicable when configuring a backend service.

Possible values: ENABLED, DISABLED

Default value: DISABLED"

		validate do |value|
			if ! [:"POSSIBLE VALUES: ENABLED", :DISABLED].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: ENABLED, DISABLED"
			end
		end

		munge(&:upcase)
	end

	newproperty(:redirectportrewrite) do
		desc "State of the port rewrite while performing HTTPS redirect. If this parameter is set to ENABLED, and the URL from the server does not contain the standard port, the port is rewritten to the standard.

Possible values: ENABLED, DISABLED

Default value: DISABLED"

		validate do |value|
			if ! [:"POSSIBLE VALUES: ENABLED", :DISABLED].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: ENABLED, DISABLED"
			end
		end

		munge(&:upcase)
	end

	newproperty(:nonfipsciphers) do
		desc "State of usage of ciphers that are not FIPS approved. Valid only for an SSL service bound with a FIPS key and certificate.

Possible values: ENABLED, DISABLED

Default value: DISABLED"

		validate do |value|
			if ! [:"POSSIBLE VALUES: ENABLED", :DISABLED].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: ENABLED, DISABLED"
			end
		end

		munge(&:upcase)
	end

	newproperty(:ssl2) do
		desc "State of SSLv2 protocol support for the SSL service.

This parameter is not applicable when configuring a backend service.

Possible values: ENABLED, DISABLED

Default value: DISABLED"

		validate do |value|
			if ! [:"POSSIBLE VALUES: ENABLED", :DISABLED].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: ENABLED, DISABLED"
			end
		end

		munge(&:upcase)
	end

	newproperty(:ssl3) do
		desc "State of SSLv3 protocol support for the SSL service.

Possible values: ENABLED, DISABLED

Default value: ENABLED"

		validate do |value|
			if ! [:"POSSIBLE VALUES: ENABLED", :DISABLED].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: ENABLED, DISABLED"
			end
		end

		munge(&:upcase)
	end

	newproperty(:tls1) do
		desc "State of TLSv1.0 protocol support for the SSL service.

Possible values: ENABLED, DISABLED

Default value: ENABLED"

		validate do |value|
			if ! [:"POSSIBLE VALUES: ENABLED", :DISABLED].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: ENABLED, DISABLED"
			end
		end

		munge(&:upcase)
	end

	newproperty(:tls11) do
		desc "State of TLSv1.1 protocol support for the SSL service. Enabled for Front-end service on MPX-CVM platform only.

Possible values: ENABLED, DISABLED

Default value: ENABLED"

		validate do |value|
			if ! [:"POSSIBLE VALUES: ENABLED", :DISABLED].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: ENABLED, DISABLED"
			end
		end

		munge(&:upcase)
	end

	newproperty(:tls12) do
		desc "State of TLSv1.2 protocol support for the SSL service. Enabled for Front-end service on MPX-CVM platform only.

Possible values: ENABLED, DISABLED

Default value: ENABLED"

		validate do |value|
			if ! [:"POSSIBLE VALUES: ENABLED", :DISABLED].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: ENABLED, DISABLED"
			end
		end

		munge(&:upcase)
	end

	newproperty(:snienable) do
		desc "State of the Server Name Indication (SNI) feature on the virtual server and service-based offload. SNI helps to enable SSL encryption on multiple domains on a single virtual server or service if the domains are controlled by the same organization and share the same second-level domain name. For example, *.sports.net can be used to secure domains such as login.sports.net and help.sports.net.

This parameter is not applicable when configuring a backend service.

Possible values: ENABLED, DISABLED

Default value: DISABLED"

		validate do |value|
			if ! [:"POSSIBLE VALUES: ENABLED", :DISABLED].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: ENABLED, DISABLED"
			end
		end

		munge(&:upcase)
	end

	newproperty(:serverauth) do
		desc "State of server authentication support for the SSL service.

Possible values: ENABLED, DISABLED

Default value: DISABLED"

		validate do |value|
			if ! [:"POSSIBLE VALUES: ENABLED", :DISABLED].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: ENABLED, DISABLED"
			end
		end

		munge(&:upcase)
	end

	newproperty(:commonname) do
		desc "Name to be checked against the CommonName (CN) field in the server certificate bound to the SSL server"
	end

	newproperty(:pushenctrigger) do
		desc "Trigger encryption on the basis of the PUSH flag value. Available settings function as follows:

* ALWAYS - Any PUSH packet triggers encryption.

* IGNORE - Ignore PUSH packet for triggering encryption.

* MERGE - For a consecutive sequence of PUSH packets, the last PUSH packet triggers encryption.

* TIMER - PUSH packet triggering encryption is delayed by the time defined in the set ssl parameter command or in the Change Advanced SSL Settings dialog box.

Possible values: Always, Merge, Ignore, Timer"

		validate do |value|
			if ! [:"POSSIBLE VALUES: ALWAYS", :MERGE, :IGNORE, :TIMER].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: ALWAYS, MERGE, IGNORE, TIMER"
			end
		end

		munge(&:upcase)
	end

	newproperty(:sendclosenotify) do
		desc "Enable sending SSL Close-Notify at the end of a transaction

Possible values: YES, NO

Default value: YES"

		validate do |value|
			if ! [:"POSSIBLE VALUES: YES", :NO].any?{ |s| s.to_s.eql? value }
				fail ArgumentError, "Valid options: POSSIBLE VALUES: YES, NO"
			end
		end

		munge(&:upcase)
	end

	newproperty(:dtlsprofilename) do
		desc "Name of the DTLS profile that contains DTLS settings for the service."
	end

	newproperty(:sslprofile) do
		desc "Name of the SSL profile that contains SSL settings for the service."
	end
end
