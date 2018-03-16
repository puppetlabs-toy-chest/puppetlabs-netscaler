require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_mode).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "nsmode"
  end

  def self.instances
    instances = []

    modes = Puppet::Provider::Netscaler.call('/config/nsmode')

    modes.delete('mode')

    modes.each do |mode|
      # map rest name to english name (ie fr to Fast Ramp)
      name = Puppet::Type::Netscaler_mode.rest_name_map[mode[0]]

      if (name != nil)
        instances << new({
          :name   => name,
          :ensure => mode[1] ? :present : :absent,
        })
      end
    end

    instances
  end

  def create
    save
  end

  def flush
    # do nothing
  end

  def destroy
    save
  end

  def save
    action = case resource[:ensure]
      when :present then 'enable'
      when :absent then 'disable'
    end

    # map english name to rest name, ie Fast Ramp to fr
    rest_name = Puppet::Type::Netscaler_mode.rest_name_map.rassoc(resource[:name])[0]

    result = Puppet::Provider::Netscaler.post("/config/nsmode", { :nsmode => { :mode => rest_name } }.to_json, {"action" => action})
  end



end

