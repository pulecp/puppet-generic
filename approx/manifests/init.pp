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
  package { "approx":; }

  # As of wheezy, approx is run from inetd.
  if $lsbdistcodename == 'lenny' or $lsbdistcodename == 'squeeze' {
    service  { "approx":
      ensure    => running,
      hasstatus => $lsbdistcodename ? {
        "lenny" => false,
        default => true,
      },
      require   => Package["approx"],
      subscribe => File["/etc/approx/approx.conf"],
    }
  }

  file { "/etc/approx/approx.conf":
    content => template("approx/approx.conf"),
    require => Package["approx"];
  }
}
