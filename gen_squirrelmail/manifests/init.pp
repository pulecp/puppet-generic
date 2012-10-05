# Author: Kumina bv <support@kumina.nl>

# Class: gen_squirrelmail
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_squirrelmail {
  package { ["squirrelmail", "squirrelmail-locales"]:
    ensure => installed,
  }
}

class gen_squirrelmail::plugin::avelsieve {
  package { "avelsieve":
    ensure => installed,
  }
}
