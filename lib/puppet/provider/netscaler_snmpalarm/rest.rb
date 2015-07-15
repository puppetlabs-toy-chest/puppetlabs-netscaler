require 'puppet/provider/netscaler'

Puppet::Type.type(:netscaler_snmpalarm).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "snmpalarm"
  end

  def self.instances
    instances = []
    alarms = Puppet::Provider::Netscaler.call('/config/snmpalarm')
    return [] if alarms.nil?

    alarms.each do |alarm|
      instances << new(
        :ensure           => :present,
        :name             => alarm['trapname'],
        :alarm_threshold  => alarm['thresholdvalue'],
        :normal_threshold => alarm['normalvalue'],
        :severity         => alarm['severity'],
        :time_interval    => alarm['time'],
        :state            => alarm['state'],
        :logging          => alarm['logging'],
      )
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :name             => :trapname,
      :alarm_threshold  => :thresholdvalue,
      :normal_threshold => :normalvalue,
      :time_interval    => :time,
    }
  end

  def immutable_properties
    [
    ]
  end
  def flush_state_args
    {
      :name_key => 'trapname',
      :name_val => resource[:name],
    }
  end

  def per_provider_munge(message)
    message
  end
end
