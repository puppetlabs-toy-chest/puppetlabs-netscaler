require 'puppet/property'

class Puppet::Property::NetscalerTrafficDomain < Puppet::Property
  def self.postinit
    @doc ||= 'Integer value that uniquely identifies the traffic domain in which you want to configure the entity. If you do not specify an ID, the entity becomes part of the default traffic domain, which has an ID of 0.

Min: 0
Max: 4096'
  end

  validate do |value|
    if ! (value =~ /\d+$/ and Integer(value).between?(0,4094))
      fail ArgumentError, "traffic_domain_id: Must be an integer between 0-4094"
    end
  end
  munge do |value|
    Integer(value)
  end
end
