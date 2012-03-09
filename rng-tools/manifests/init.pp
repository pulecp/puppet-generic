# Author: Kumina bv <support@kumina.nl>

# Class: rng-tools
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class rng-tools {
  kpackage { "rng-tools":
    ensure => latest;
  }

  file { "/etc/default/rng-tools":
    content  => template("rng-tools/rng-tools"),
    notify   => Service["rng-tools"],
    require  => Package["rng-tools"];
  }

  service { "rng-tools":
    ensure    => running,
    pattern   => "/usr/sbin/rngd",
    hasstatus => false,
    require   => File["/etc/default/rng-tools"];
  }
}
