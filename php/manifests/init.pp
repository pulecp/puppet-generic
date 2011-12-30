# Author: Kumina bv <support@kumina.nl>

# Class: php::common
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class php::common {
}

# Class: php::php5::common
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class php::php5::common {
  $phpversion = 5
  include php::common
}

# Class: php::php5::modphp
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class php::php5::modphp {
  include php::php5::common

  package { "libapache2-mod-php5":
    ensure => installed,
  }
}

# Class: php::php5::cgi
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class php::php5::cgi {
  include php::php5::common

  package { "php5-cgi":
    ensure => installed,
  }
}

# Class: php::php5::cli
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class php::php5::cli {
  include php::php5::common

  package { "php5-cgi":
    ensure => installed,
  }
}

# Class: php::php4::common
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class php::php4::common {
  $phpversion = 4
  include php::common
}

# Class: php::php4::modphp
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class php::php4::modphp {
  include php::php4::common

  package { "libapache2-mod-php4":
    ensure => installed,
  }
}

# Class: php::php4::cgi
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class php::php4::cgi {
  include php::php4::common

  package { "php4-cgi":
    ensure => installed,
  }
}

# Class: php::php4::cli
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class php::php4::cli {
  include php::php4::common

  package { "php4-cli":
    ensure => installed,
  }
}
