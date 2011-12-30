# Author: Kumina bv <support@kumina.nl>

# Class: postgrey
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class postgrey {
  package { "postgrey":
    ensure => installed;
  }

  service { "postgrey":
    require => Package["postgrey"],
    enable => true;
  }
}
