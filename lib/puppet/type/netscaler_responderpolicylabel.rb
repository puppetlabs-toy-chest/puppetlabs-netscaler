require 'puppet/parameter/netscaler_name'
require 'puppet/property/netscaler_truthy'
require 'puppet/property/netscaler_traffic_domain'

Puppet::Type.newtype(:netscaler_responderpolicylabel) do
  @doc = 'Manage basic netscaler responder action objects.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)
  #XXX Validat with the below
  #ensure: change from absent to present failed: Could not set 'present' on ensure: REST failure: HTTP status code 400 detected.  Body of failure is: { "errorcode": 1075, "message": "Invalid name; names must begin with an alphanumeric character or underscore and must contain only alphanumerics, '_', '#', '.', ' ', ':', '@', '=' or '-' [name, hunner's website]", "severity": "ERROR" } at 55:/etc/puppetlabs/puppet/environments/produc

  newproperty(:type) do
    desc "Type of responses sent by the policies bound to this policy label."
    validate do |value|
      if ! [
        :HTTP, 
        :OTHERTCP,
        :SIP_UDP, 
        :MYSQL, 
        :MSSQL, 
        :NAT, 
        :DIAMETER,
      ].any?{ |s| s.to_s.eql? value }
        fail ArgumentError, "Valid options: HTTP, OTHERTCP, SIP_UDP, MYSQL, MSSQL, NAT, DIAMETER" 
      end
    end

    munge(&:upcase)
  end

  newproperty(:comments) do
    desc "Any comments to preserve information about this responder policy label."
  end
end
