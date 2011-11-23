# Author: Kumina bv <support@kumina.nl>

# Class: gen_smartmontools
#
# Actions:
#  Install smartmontools
#
class gen_smartmontools {
  package { "smartmontools":
    ensure => latest;
  }
}
