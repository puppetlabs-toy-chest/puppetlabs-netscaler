require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_sslvserver).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def self.instances
    instances = []
    sslvservers = Puppet::Provider::Netscaler.call('/config/sslvserver')
    return [] if sslvservers.nil?

		sslvservers.each do |sslvserver|
			instances << new({
				:ensure              => :present,
				:name                => sslvserver['vservername'],
				:cipherdetails       => sslvserver['cipherdetails'],
				:cleartextport       => sslvserver['cleartextport'],
				:dh                  => sslvserver['dh'],
				:dh_file             => sslvserver['dhfile'],
				:dh_count            => sslvserver['dhcount'],
				:ersa                => sslvserver['ersa'],
				:ersacount           => sslvserver['ersacount'],
				:sessreuse           => sslvserver['sessreuse'],
				:sesstimeout         => sslvserver['sesstimeout'],
				:cipherredirect      => sslvserver['cipherredirect'],
				:sslv2redirect       => sslvserver['sslv2redirect'],
				:clientauth          => sslvserver['clientauth'],
				:sslredirect         => sslvserver['sslredirect'],
				:priority            => sslvserver['priority'],
				:polinherit          => sslvserver['polinherit'],
				:redirectportrewrite => sslvserver['redirectportrewrite'],
				:nonfipsciphers      => sslvserver['nonfipsciphers'],
				:ssl2                => sslvserver['ssl2'],
				:ssl3                => sslvserver['ssl3'],
				:tls1                => sslvserver['tls1'],
				:tls11               => sslvserver['tls11'],
				:tls12               => sslvserver['tls12'],
				:snienable           => sslvserver['snienable'],
				:service             => sslvserver['service'],
				:invoke              => sslvserver['invoke'],
				:pushenctrigger      => sslvserver['pushenctrigger'],
				:ca                  => sslvserver['ca'],
				:snicert             => sslvserver['snicert'],
				:skipcaname          => sslvserver['skipcaname'],
				:sendclosenotify     => sslvserver['sendclosenotify'],
				:dtlsflag            => sslvserver['dtlsflag'],
			})
		end

		instances
	end

	mk_resource_methods

	# Map irregular attribute names for conversion in the message.
	def property_to_rest_mapping
		{
			:dh_file  => :dhfile,
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
		"sslvserver"
	end
end
