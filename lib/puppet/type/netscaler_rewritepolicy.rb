require 'puppet/parameter/netscaler_name'
require 'puppet/property/netscaler_truthy'
require 'puppet/property/netscaler_traffic_domain'

Puppet::Type.newtype(:netscaler_rewritepolicy) do
  @doc = 'Manage basic netscaler rewrite policy objects.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)

  newproperty(:expression) do
    desc "Expression to be used by rewrite policy. It has to be a boolean PI rule expression."

  end

  newproperty(:action) do
    desc "Rewrite action to be used by the policy."

  end

  newproperty(:undefined_result_action) do
    desc "A rewrite action, to be used by the policy when the rule evaluation turns out to be undefined. The undef action can be NOREWRITE, RESET or DROP"

    validate do |value|
      if ! [:NOREWRITE,:RESET,:DROP].any?{ |s| s.casecmp(value.to_sym) == 0 }
        fail ArgumentError, "Valid options: NOREWRITE, RESET, DROP"
      end
    end

    munge do |value|
      value.upcase
    end

  end

  newproperty(:comments) do
    desc "Comments associated with this rewrite policy."

  end

  newproperty(:log_action) do
    desc "The log action associated with the rewrite policy"

  end
  
end
