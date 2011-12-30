# Author: Kumina bv <support@kumina.nl>

# Class: approx
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class approx {
  kpackage { "approx":; }

  service  { "approx":
    ensure => running,
    hasstatus => $lsbdistcodename ? {
      "lenny" => false,
      default => true,
    },
    require => Package["approx"],
    subscribe => File["/etc/approx/approx.conf"],
  }

  kfile { "/etc/approx/approx.conf":
    source => "approx/approx.conf",
    require => Package["approx"];
  }
}
