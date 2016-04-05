require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_sslservice).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
	def self.instances
		instances = []
		sslservices = Puppet::Provider::Netscaler.call('/config/sslservice')
		return [] if sslservices.nil?

		sslservices.each do |sslservice|
			instances << new({
				:ensure              => :present,
				:name                => sslservice['servicename'],
				:cipherdetails       => sslservice['cipherdetails'],
				:dh                  => sslservice['dh'],
				:dhcount             => sslservice['dhcount'],
				:ersa                => sslservice['ersa'],
				:ersacount           => sslservice['ersacount'],
				:sessreuse           => sslservice['sessreuse'],
				:sesstimeout         => sslservice['sesstimeout'],
				:cipherredirect      => sslservice['cipherredirect'],
				:sslv2redirect       => sslservice['sslv2redirect'],
				:clientauth          => sslservice['clientauth'],
				:sslredirect         => sslservice['sslredirect'],
				:redirectportrewrite => sslservice['redirectportrewrite'],
				:nonfipsciphers      => sslservice['nonfipsciphers'],
				:ssl2                => sslservice['ssl2'],
				:ssl3                => sslservice['ssl3'],
				:tls1                => sslservice['tls1'],
				:tls11               => sslservice['tls11'],
				:tls12               => sslservice['tls12'],
				:snienable           => sslservice['snienable'],
				:serverauth          => sslservice['serverauth'],
				:invoke              => sslservice['invoke'],
				:service             => sslservice['service'],
				:priority            => sslservice['priority'],
				:polinherit          => sslservice['polinherit'],
				:ca                  => sslservice['ca'],
				:snicert             => sslservice['snicert'],
				:skipcaname          => sslservice['skipcaname'],
				:sendclosenotify     => sslservice['sendclosenotify'],
				:dtlsflag            => sslservice['dtlsflag'],
			})
		end

		instances
	end

	mk_resource_methods

	# Map irregular attribute names for conversion in the message.
	def property_to_rest_mapping
		{
			:dh_count => :dhcount,
		}
	end

	def immutable_properties
		[]
	end

	def per_provider_munge(message)
		message
	end

	def netscaler_api_type
		"sslservice"
	end
end
