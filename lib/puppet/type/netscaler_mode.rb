Puppet::Type.newtype(:netscaler_mode) do
  desc 'Netscaler modes'

  apply_to_device

  ensurable

  def self.rest_name_map
    {
        'fr'    => 'Fast Ramp',
        'l2'    => 'Layer 2 mode',
        'usip'  => 'Use Source IP',
        'cka'   => 'Client Keep-alive',
        'tcpb'  => 'TCP Buffering',
        'mbf'   => 'MAC-based forwarding',
        'edge'  => 'Edge configuration',
        'usnip' => 'Use Subnet IP',
        'l3'    => 'Layer 3 mode (ip forwarding)',
        'pmtud' => 'Path MTU Discovery',
        'mediaclassification'   => 'Media Classification',
        'sradv' =>      'Static Route Advertisement',
        'dradv' =>      'Direct Route Advertisement',
        'iradv' =>      'Intranet Route Advertisement',
        'sradv6'        =>      'Ipv6 Static Route Advertisement',
        'dradv6'        =>      'Ipv6 Direct Route Advertisement',
        'bridgebpdus'   =>      'Bridge BPDUs',
        'rise_apbr'     =>      'RISE APBR Advertisement',
        'rise_rhi'      =>      'RISE RHI Advertisement',
        'ulfd'  =>      'Unified Logging',
    }
  end

  newparam(:name, :namevar => true) do
    desc 'Mode name'

    validate do |value|
      if ! Puppet::Type::Netscaler_mode.rest_name_map.values.any?{ |s| s <=> value }
        fail ArgumentError, "Valid options: " + Puppet::Type::Netscaler_mode.rest_name_map.values.to_s
      end
    end
  end

  def self.title_patterns
    key_pattern =  self.rest_name_map.keys.join('|')
    [
      [ /^(#{key_pattern})$/i, [ [ :name, Proc.new { |value|  self.rest_name_map[value.downcase] } ] ] ] ,
      [ /(.*)/m, [ [ :name ] ] ]
    ]
  end
end

