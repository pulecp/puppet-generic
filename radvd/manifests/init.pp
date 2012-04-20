# Author: Kumina bv <support@kumina.nl>

# Class: radvd::server
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class radvd::server {
  package { "radvd":
    ensure => latest;
  }

  service { "radvd":
    subscribe => File["/etc/radvd.conf"],
    require => File["/etc/radvd.conf"],
    ensure => running;
  }

  file { "/etc/radvd.conf":
    require => Package["radvd"];
  }
}
