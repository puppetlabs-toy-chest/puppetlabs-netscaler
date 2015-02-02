require 'puppet/provider/netscaler'

class Puppet::Provider::NetscalerBinding < Puppet::Provider::Netscaler
  def flush
    if @property_hash != {}
      #XXX Maybe we should delete/create them?
      err "Bindings may not be modified after creation"
    end
  end

  def immutable_properties
    []
  end

  # We have to override this because some properties actually have
  # underscores... (like monitor_name)
  def remove_underscores(hash)
    hash
  end
end
