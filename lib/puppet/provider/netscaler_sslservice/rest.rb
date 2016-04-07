require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_sslservice).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  # Provider for sslservice: Sets the advanced SSL configuration for an SSL service.
  def self.instances
    instances = []
    sslservices = Puppet::Provider::Netscaler.call('/config/sslservice')
    return [] if sslservices.nil?

    sslservices.each do |sslservice|
      instances << new({
        :ensure                => :present,
        :name                  => sslservice['servicename'],
        :cipher_redirect       => sslservice['cipherredirect'],
        :cipher_url            => sslservice['cipherurl'],
        :client_auth           => sslservice['clientauth'],
        :client_cert           => sslservice['clientcert'],
        :common_name           => sslservice['commonname'],
        :dh                    => sslservice['dh'],
        :dh_count              => sslservice['dhcount'],
        :dh_file               => sslservice['dhfile'],
        :dh_key_exp_size_limit => sslservice['dhkeyexpsizelimit'],
        :dtls_profile_name     => sslservice['dtlsprofilename'],
        :ersa                  => sslservice['ersa'],
        :ersa_count            => sslservice['ersacount'],
        :non_fips_ciphers      => sslservice['nonfipsciphers'],
        :push_enc_trigger      => sslservice['pushenctrigger'],
        :redirect_port_rewrite => sslservice['redirectportrewrite'],
        :send_close_notify     => sslservice['sendclosenotify'],
        :server_auth           => sslservice['serverauth'],
        :sess_reuse            => sslservice['sessreuse'],
        :sess_timeout          => sslservice['sesstimeout'],
        :sni_enable            => sslservice['snienable'],
        :ssl2                  => sslservice['ssl2'],
        :ssl3                  => sslservice['ssl3'],
        :ssl_profile           => sslservice['sslprofile'],
        :ssl_redirect          => sslservice['sslredirect'],
        :sslv2_redirect        => sslservice['sslv2redirect'],
        :sslv2_url             => sslservice['sslv2url'],
        :tls1                  => sslservice['tls1'],
        :tls11                 => sslservice['tls11'],
        :tls12                 => sslservice['tls12'],
      })
    end

    instances
  end

  mk_resource_methods

  # Map irregular attribute names for conversion in the message.
  def property_to_rest_mapping
    {
      :cipher_redirect       => :cipherredirect,
      :cipher_url            => :cipherurl,
      :client_auth           => :clientauth,
      :client_cert           => :clientcert,
      :common_name           => :commonname,
      :dh                    => :dh,
      :dh_count              => :dhcount,
      :dh_file               => :dhfile,
      :dh_key_exp_size_limit => :dhkeyexpsizelimit,
      :dtls_profile_name     => :dtlsprofilename,
      :ersa                  => :ersa,
      :ersa_count            => :ersacount,
      :non_fips_ciphers      => :nonfipsciphers,
      :push_enc_trigger      => :pushenctrigger,
      :redirect_port_rewrite => :redirectportrewrite,
      :send_close_notify     => :sendclosenotify,
      :server_auth           => :serverauth,
      :sess_reuse            => :sessreuse,
      :sess_timeout          => :sesstimeout,
      :sni_enable            => :snienable,
      :ssl2                  => :ssl2,
      :ssl3                  => :ssl3,
      :ssl_profile           => :sslprofile,
      :ssl_redirect          => :sslredirect,
      :sslv2_redirect        => :sslv2redirect,
      :sslv2_url             => :sslv2url,
      :tls1                  => :tls1,
      :tls11                 => :tls11,
      :tls12                 => :tls12,
    }
  end

  def immutable_properties
    []
  end

  def per_provider_munge(message)
    message
  end

  def netscaler_api_type
    "sslservice"
  end
end
