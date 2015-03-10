Puppet::Type.newtype(:netscaler_nshostname) do
  @doc = 'Manage netscaler NTP server objects.'

  apply_to_device
  ensurable do
    defaultto :present
  end

  newparam(:name, :namevar => true) do #<String>
    desc "Host name for the NetScaler appliance."
  end

  newproperty(:ownernode) do #<Double>
    desc "ID of the cluster node for which you are setting the hostname. Can be configured only through the cluster IP address.
Minimum value = 0
Maximum value = 31"
  end
end
