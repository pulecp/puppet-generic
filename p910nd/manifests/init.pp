# Author: Kumina bv <support@kumina.nl>

# Class: p910nd::server
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class p910nd::server {
  package { "p910nd":; }

  service {
    "p910nd":
      ensure => running,
      hasstatus => $lsbdistcodename ? {
        "lenny" => false,
        default => true,
      },
      pattern => "p9100d",
      require => File["/etc/default/p910nd"],
      subscribe => File["/etc/default/p910nd"];
  }

  file {
    "/etc/default/p910nd":
      require => Package["p910nd"];
  }
}
