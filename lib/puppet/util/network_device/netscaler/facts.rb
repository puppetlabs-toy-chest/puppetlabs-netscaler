class Puppet::Util::NetworkDevice::Netscaler::Facts
  attr_reader :transport

  def initialize(transport)
    @transport = transport
  end

  def retrieve
    facts = {}
    facts.merge(parse_device_facts)
  end

  def parse_device_facts
    facts = {}
    result = @transport.call('/stat/ns')
    [
      :cpuusage,
      :memuseinmb,
      :numcpus,
      :starttime,
    ].each do |fact|
      facts[fact] = result[fact.to_s]
    end
    result = @transport.call('/config/nsconfig')
    [
      :ipaddress,
      :netmask,
      :systemtype,
      :primaryip,
      :timezone,
      :lastconfigchangedtime,
      :lastconfigsavetime,
      :systemtime,
    ].each do |fact|
      facts[fact] = result[fact.to_s]
    end
    facts[:version]         = @transport.call('/config/nsversion')['version']
    facts[:macaddress]      = @transport.call('/config/Interface').first['mac']
    facts[:operatingsystem] = :Netscaler
    #facts[:fqdn]            = facts[:hostname]

    return facts
  end
end
