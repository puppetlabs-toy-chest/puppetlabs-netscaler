require 'puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_sslvserver).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  # Provider for sslvserver: Sets advanced SSL configuration for an SSL virtual server.
  def self.instances
    instances = []
    sslvservers = Puppet::Provider::Netscaler.call('/config/sslvserver')
    return [] if sslvservers.nil?

    sslvservers.each do |sslvserver|
      instances << new({
        :ensure                => :present,
        :name                  => sslvserver['vservername'],
        :cipher_redirect       => sslvserver['cipherredirect'],
        :cipher_url            => sslvserver['cipherurl'],
        :clear_text_port       => sslvserver['cleartextport'],
        :client_auth           => sslvserver['clientauth'],
        :client_cert           => sslvserver['clientcert'],
        :dh                    => sslvserver['dh'],
        :dh_count              => sslvserver['dhcount'],
        :dh_file               => sslvserver['dhfile'],
        :dh_key_exp_size_limit => sslvserver['dhkeyexpsizelimit'],
        :dtls_profile_name     => sslvserver['dtlsprofilename'],
        :ersa                  => sslvserver['ersa'],
        :ersa_count            => sslvserver['ersacount'],
        :non_fips_ciphers      => sslvserver['nonfipsciphers'],
        :push_enc_trigger      => sslvserver['pushenctrigger'],
        :redirect_port_rewrite => sslvserver['redirectportrewrite'],
        :send_close_notify     => sslvserver['sendclosenotify'],
        :sess_reuse            => sslvserver['sessreuse'],
        :sess_timeout          => sslvserver['sesstimeout'],
        :sni_enable            => sslvserver['snienable'],
        :ssl2                  => sslvserver['ssl2'],
        :ssl3                  => sslvserver['ssl3'],
        :ssl_profile           => sslvserver['sslprofile'],
        :ssl_redirect          => sslvserver['sslredirect'],
        :sslv2_redirect        => sslvserver['sslv2redirect'],
        :sslv2_url             => sslvserver['sslv2url'],
        :tls1                  => sslvserver['tls1'],
        :tls11                 => sslvserver['tls11'],
        :tls12                 => sslvserver['tls12'],
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
      :clear_text_port       => :cleartextport,
      :client_auth           => :clientauth,
      :client_cert           => :clientcert,
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
    "sslvserver"
  end
end
