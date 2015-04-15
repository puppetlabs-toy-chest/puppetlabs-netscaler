require 'puppet/provider/netscaler'

Puppet::Type.type(:netscaler_config).provide(:rest, parent: Puppet::Provider::Netscaler) do
  def netscaler_api_type
    "nsconfig"
  end

  def self.instances
    instances = []
    config = Puppet::Provider::Netscaler.call('/config/nsconfig')
    return [] if config.nil?

      instances << new(
        :ensure                  => :present,
        :name                    => 'default',
        :ipaddress               => config['ipaddress'],
        :netmask                 => config['netmask'],
        :nsvlan                  => config['nsvlan'],
        :ifnum                   => config['ifnum'],
        :tagged                  => config['tagged'],
        :httpport                => config['httpport'],
        :maxconn                 => config['maxconn'],
        :maxreq                  => config['maxreq'],
        :cip                     => config['cip'],
        :cipheader               => config['cipheader'],
        :cookieversion           => config['cookieversion'],
        :securecookie            => config['securecookie'],
        :pmtumin                 => config['pmtumin'],
        :pmtutimeout             => config['pmtutimeout'].to_s,
        :ftpportrange            => config['ftpportrange'],
        :crportrange             => config['crportrange'],
        :timezone                => config['timezone'],
        :grantquotamaxclient     => config['grantquotamaxclient'],
        :exclusivequotamaxclient => config['exclusivequotamaxclient'],
        :grantquotaspillover     => config['grantquotaspillover'],
        :exclusivequotaspillover => config['exclusivequotaspillover'],
        :nwfwmode                => config['nwfwmode'],
      )

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
    }
  end

  def immutable_properties
    [
    ]
  end

  def required_properties
    [
      :ipaddress,
      :netmask,
      :tagged,
      :nsvlan,
      :ifnum,
    ]
  end

  def per_provider_munge(message)
    message.delete(:name)
    message
  end
end
