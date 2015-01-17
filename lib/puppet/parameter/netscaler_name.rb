require 'puppet/parameter'

class Puppet::Parameter::NetscalerName < Puppet::Parameter
  def self.postinit
    @doc ||= "Name for the object. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters."
  end

  validate do |value|
    fail ArgumentError, "#{name} must be a String" unless value.is_a?(String)
    #fail ArgumentError, "#{name} must match the pattern /Partition/name" unless value.match(%r{/\w+/[\w\.-]+$})
  end
end
