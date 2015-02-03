require 'faraday/parameters'

class Puppet::Util::NetworkDevice::Transport::DoNotEncoder
  include ::Faraday::NestedParamsEncoder
  def self.encode(params)
    if params and ! params.empty?
      params.collect do |k,v|
        "#{k}=#{v}"
      end.join '&'
    end
  end
end
