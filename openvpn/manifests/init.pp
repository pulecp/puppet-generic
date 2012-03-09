# Author: Kumina bv <support@kumina.nl>

# Class: openvpn::common
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class openvpn::common {
  kpackage { "openvpn":; }
}

# Class: openvpn::server
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class openvpn::server {
  include openvpn::common

  file {
    "/etc/openvpn/server.conf":
      content => template("openvpn/server.conf"),
      require => [Package["openvpn"], File["/var/lib/openvpn"]];
    "/var/lib/openvpn":
      ensure => "directory",
      mode => 750;
  }

  service { "openvpn":
    subscribe => File["/etc/openvpn/server.conf"],
    hasstatus => $lsbdistcodename ? {
      "lenny" => false,
      default => undef,
    },
    ensure    => running;
  }

}

# Class: openvpn::client
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class openvpn::client {
  include openvpn::common

  file { "/etc/openvpn/client.conf":
    content => template("openvpn/client.conf"),
    require => Package["openvpn"],
  }
}
