# Author: Kumina bv <support@kumina.nl>

# Class: phpldapadmin
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class phpldapadmin {
  package { "phpldapadmin":
    ensure => installed,
  }
}
