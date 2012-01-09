# Author: Kumina bv <support@kumina.nl>

# Class: hylafax::server
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class hylafax::server {
  # against policy: include generic classes
  include gen_base::libfreetype6
  include gen_base::libcups2
  include gen_base::libcupsimage2

  kpackage { "hylafax-server":
    ensure => latest,
  }

  service {
    "hylafax":
      require   => Package["hylafax-server"],
      hasstatus => $lsbdistcodename ? {
        "lenny"    => false,
        "squeeze"  => false,
        default    => undef,
      },
      pattern   => "hfaxd",
      ensure    => running;
  }
}
