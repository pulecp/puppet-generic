# Author: Kumina bv <support@kumina.nl>

# Class: arpwatch
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class arpwatch {
  package { "arpwatch":; }

  service { "arpwatch":
    ensure    => running,
    hasstatus => false,
    require   => File["/etc/default/arpwatch"],
    subscribe => File["/etc/default/arpwatch"];
  }

  file { "/etc/default/arpwatch":
    require => Package["arpwatch"];
  }
}
