# Author: Kumina bv <support@kumina.nl>

# Class: iaxmodem
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class iaxmodem {
  package {
    "iaxmodem":
      ensure => present;
  }

  service {
    "iaxmodem":
      require   => Package["iaxmodem"],
      ensure    => running,
      hasstatus => $lsbdistcodename ? {
        "lenny" => false,
        default => undef,
      };
  }
}
