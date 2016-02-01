require_relative('../../puppet/parameter/netscaler_name')
require_relative('../../puppet/property/netscaler_truthy')
require_relative('../../puppet/property/netscaler_traffic_domain')

Puppet::Type.newtype(:netscaler_responderaction) do
  @doc = 'Manage basic netscaler responder action objects.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)
  #XXX Validat with the below
  #ensure: change from absent to present failed: Could not set 'present' on ensure: REST failure: HTTP status code 400 detected.  Body of failure is: { "errorcode": 1075, "message": "Invalid name; names must begin with an alphanumeric character or underscore and must contain only alphanumerics, '_', '#', '.', ' ', ':', '@', '=' or '-' [name, hunner's website]", "severity": "ERROR" } at 55:/etc/puppetlabs/puppet/environments/produc

  newproperty(:type) do
    desc "Type of responder action."
    validate do |value|
      if ! [
        :noop, 
        :respondwith,
        :redirect,
        :sqlresponse_ok,
        :sqlresponse_error,
      ].any?{ |s| s.to_s.eql? value }
        fail ArgumentError, "Valid options: noop, respondwith, redirect,  sqlresponse_ok, sqlresponse_error" 
      end
    end

    munge(&:downcase)
  end

  newproperty(:expression) do
    desc "Expression specifying what to respond with. Typically a URL for redirect policies or a default-syntax expression."
  end

  #linked to type :repondwithhtmlpage
  #newproperty(:htmlpage) do
  #  desc "For respondwith htmlpage policies, name of the HTML page object to use as the response."
  #end

  #linked with :respondwidth :redirect
  newproperty(:bypass_safety_check, :parent => Puppet::Property::NetscalerTruthy) do
    truthy_property("Bypass the safety check, allowing potentially unsafe expressions.", "YES", "NO")
  end

  newproperty(:comments) do
    desc "Any information about the responder action."
  end
end
