# Author: Kumina bv <support@kumina.nl>

# Class: varnish
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class varnish {
  package { "varnish":
    ensure => installed,
  }

  service { "varnish":
    ensure => running,
    require => Package["varnish"],
  }

  kfile { "/etc/default/varnish":
    content => template("varnish/default/varnish"),
    notify  => Service["varnish"],
  }
}
