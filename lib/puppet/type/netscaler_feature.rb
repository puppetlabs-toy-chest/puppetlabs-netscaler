Puppet::Type.newtype(:netscaler_feature) do
  desc 'Netscaler features'
  
  apply_to_device

  ensurable
  
  newparam(:name, :namevar => true) do
    desc 'Feature name'
    
    validate do |value|
      if ! [:wl,:sp,:lb,:cs,:cr,:sc,:cmp,:pq,:ssl,:gslb,:hdosp,:cf,:ic,:sslvpn,:aaa,:ospf,:rip,:bgp,:rewrite,:ipv6pt,:appfw,:responder,:htmlinjection,:push,:appflow,:cloudbridge,:isis,:ch,:appqoe,:diskcaching,:vpath,:contentaccelerator,:rise,:feo].any?{ |s| s.casecmp(value.to_sym) == 0 }
        fail ArgumentError, "Valid options: wl, sp, lb, cs, cr, sc, cmp, pq, ssl, gslb, hdosp, cf, ic, sslvpn, aaa, ospf, rip, bgp, rewrite, ipv6pt, appfw, responder, htmlinjection, push, appflow, cloudbridge, isis, ch, appqoe, diskcaching, vpath, contentaccelerator, rise, feo"
      end
    end
  end
end