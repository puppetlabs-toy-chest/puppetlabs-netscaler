require 'puppet/parameter/netscaler_name'
require 'puppet/property/netscaler_truthy'
require 'puppet/property/netscaler_traffic_domain'

Puppet::Type.newtype(:netscaler_rewritepolicylabel) do
  @doc = 'Manage basic netscaler rewrite policy label objects.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)

  newproperty(:transform_name) do
    desc "Types of transformations allowed by the policies bound to the label.
    The following types are supported: 
    * http_req - HTTP requests 
    * http_res - HTTP responses 
    * othertcp_req - Non-HTTP TCP requests 
    * othertcp_res - Non-HTTP TCP responses 
    * url - URLs 
    * text - Text strings 
    * clientless_vpn_req - NetScaler clientless VPN requests 
    * clientless_vpn_res - NetScaler clientless VPN responses 
    * sipudp_req - SIP requests 
    * sipudp_res - SIP responses 
    * diameter_req - DIAMETER requests 
    * diameter_res - DIAMETER responses."

    validate do |value|
      if ! [
        :http_req, 
        :http_res, 
        :othertcp_req, 
        :othertcp_res, 
        :url, 
        :text, 
        :clientless_vpn_req, 
        :clientless_vpn_res, 
        :sipudp_req, 
        :sipudp_res, 
        :diameter_req, 
        :diameter_res
      ].any?{ |s| s.casecmp(value.to_sym) == 0 }
        fail ArgumentError, "Valid options: http_req, http_res, othertcp_req, othertcp_res, url, text, clientless_vpn_req, clientless_vpn_res, sipudp_req, sipudp_res, diameter_req, diameter_res" 
      end
    end

    munge do |value|
      value.downcase
    end

  end

  newproperty(:comments) do
    desc "Any comments to preserve information about this rewrite policy label."
  end
end
