# Author: Kumina bv <support@kumina.nl>

# Class: squirrelmail
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class squirrelmail {
  package { ["squirrelmail", "squirrelmail-locales"]:
    ensure => installed,
  }
}
