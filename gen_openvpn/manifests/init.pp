class gen_openvpn {
  kservice { 'openvpn':; }
  file { '/var/lib/openvpn':
    ensure => directory,
    mode => 750;
  }
}

class gen_openvpn::server ($ca_cert, $certname=$fqdn, $subnet, $subnet_mask ) {
  include gen_openvpn
  concat { '/etc/openvpn/server.conf':; }

  concat::add_content { 'openvpn server main':
    content => template('gen_openvpn/server.conf');
  }

  file { '/etc/openvpn/server':
    ensure => directory;
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
