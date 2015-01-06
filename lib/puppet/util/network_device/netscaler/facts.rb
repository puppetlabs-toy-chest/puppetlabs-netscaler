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
    result = @transport.ns_stat('/ns')
    [
      :cpuusage,
      :memuseinmb,
      :numcpus,
      :starttime,
    ].each do |fact|
      facts[fact] = result[fact.to_s]
    end
    result = @transport.ns_config('/nsconfig')
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
    facts[:version]         = @transport.ns_config('/nsversion')['version']
    facts[:macaddress]      = @transport.ns_config('/Interface').first['mac']
    facts[:operatingsystem] = :Netscaler
    require'pry';binding.pry
    #facts[:fqdn]            = facts[:hostname]

    return facts
  end
end
