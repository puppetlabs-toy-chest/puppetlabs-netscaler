Include the netscaler class:

```puppet
node 'device certname' {
	include 'netscaler'
}
```

Add configuration in your hiera tree:

```yaml
netscaler::certificates:
  your.domain.example.net:
    certificate_filename: /nsconfig/ssl/your.domain.example.net.cert
    key_filename: /nsconfig/ssl/your.domain.example.net.key
    linkcert_keyname: Terena-SSL-CA3-chain

netscaler::servers:
  SRV_backend-server-1:
    address: 10.0.0.1
  SRV_backend-server-2:
    address: 10.0.0.2

netscaler::services:
  SVC_backend-server-1_8443:
    port: 8443
    protocol: SSL
    server_name: SRV_backend-server-1
  SVC_backend-server-2_8443:
    port: 8443
    protocol: SSL
    server_name: SRV_backend-server-2

netscaler::lbvservers:
  LBVSRV_your.domain.example.net_HTTPS:
    service_type: SSL
    services:
      - SVC_backend-server-1_8443
      - SVC_backend-server-2_8443
    ssl:
      ciphers:
        - your.domain.example.net
      certkeys:
        - your.domain.example.net

netscaler::csvservers:
  CSVSRV_your.domain.example.net:
    ip_address: 1.2.3.4
    port: 80
    service_type: HTTP
    default_lbvserver: LBVSRV_your.domain.example.net_HTTPS
  CSVSRV_your.domain.example.net_HTTPS:
    ip_address: 1.2.3.4
    port: 443
    service_type: SSL
    default_lbvserver: LBVSRV_your.domain.example.net_HTTPS
```

This will configure:
* two csvservers (one for http, one for https),
* a single lbvserver (only https),
* two backend servers,
* two services (each one one of the backend servers).

Your backend servers are listening on 8443 (https protocol). You have a certificate pair already uploaded to the netscaler in the 'right' location (/nsconfig/ssl/) and a preconfigured certificate to be linked for the chain (Terena-SSL-CA3-chain).
