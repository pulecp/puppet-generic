class gen_openvpn {
  kservice { 'openvpn':; }
  file { '/var/lib/openvpn':
    ensure => directory,
    require => Package['openvpn'],
    mode => 750;
  }
}

class gen_openvpn::server ($ca_cert, $certname=$fqdn, $subnet, $subnet_mask, $dh_location, $push_gateway=false, $crl_location=false) {
  include gen_openvpn
  concat { '/etc/openvpn/server.conf':
    require => Package['openvpn'],
    notify  => Service['openvpn'];
  }

  concat::add_content { 'openvpn server main':
    content => template('gen_openvpn/server.conf'),
    target  => '/etc/openvpn/server.conf';
  }

  file {
    '/etc/openvpn/server':
      ensure  => directory,
      require => Package['openvpn'];
    '/etc/openvpn/server/dh.pem':
      content => template($dh_location);
    # Needed because OpenVPN/OpenSSL complains about it.
    '/usr/share/openssl-blacklist/blacklist.RSA-4096':
      ensure  => file,
      replace => false;
  }
}

define gen_openvpn::server::route ($network, $network_mask) {
  concat::add_content { "openvpn route ${name}":
    content => "#${name}\npush \"route ${network} ${network_mask}\"",
    target  => '/etc/openvpn/server.conf';
  }
}

define gen_openvpn::client ($ca_cert, $remote_host=$name, $certname=$fqdn) {
  include gen_openvpn
  file { "/etc/openvpn/${name}.conf":
    content => template('gen_openvpn/client.conf'),
    require => Package['openvpn'],
    notify  => Service['openvpn'];
  }
}
