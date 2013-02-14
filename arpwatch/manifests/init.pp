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

class arpwatch::disable {
  include arpwatch

  Package <| title == 'arpwatch' |> {
    ensure => absent,
  }

  Service <| title == 'arpwatch' |> {
    ensure => stopped,
    enable => false,
  }

  File <| title == '/etc/default/arpwatch' |> {
    ensure => absent,
  }
}
