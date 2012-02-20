# Author: Kumina bv <support@kumina.nl>

# Class: gen_php5::common
#
# Actions:
#  Setup default stuff for PHP5.
#
# Depends:
#  gen_puppet
#
class gen_php5::common {
  kpackage { "php5-common":
    ensure => latest,
  }
}

# Class: gen_php5::modphp
#
# Actions:
#  If the server supports it, setup mod_php5.
#
# Depends:
#  gen_puppet
#
class gen_php5::modphp($http_type="apache") {
  include gen_php5::common

  if $http_type == "apache" {
    kpackage { "libapache2-mod-php5":
      ensure => latest,
    }
  } else {
    fail("Unknown http server: $http_type")
  }
}

# Class: gen_php5::cgi
#
# Actions:
#  Setup the packages needed to use PHP5 in a CGI setup. This only sets up
#  the requirements for PHP5, your webserver might need other packages.
#
# Depends:
#  gen_puppet
#
class gen_php5::cgi {
  include gen_php5::common

  kpackage { "php5-cgi":
    ensure => latest,
  }
}

# Class: gen_php5::cli
#
# Actions:
#  Setup the PHP5 cli binaries.
#
# Depends:
#  gen_puppet
#
class gen_php5::cli {
  include gen_php5::common

  kpackage { "php5-cli":
    ensure => latest,
  }
}

# Class: gen_php5::apc
#
# Actions:
#  Install and setup APC
#
# Depends:
#  gen_puppet
#
class gen_php5::apc {
  include gen_php5::common

  kpackage { "php-apc":
    ensure => latest,
  }
}

# Class: gen_php5::pear
#
# Actions:
#  Install PEAR for PHP5.
#
# Depends:
#  gen_puppet
#
class gen_php5::pear {
  include gen_php5::common

  kpackage { "php-pear":
    ensure => latest,
  }
}

# Class: gen_php5::curl
#
# Actions:
#  Install curl extensions for PHP5.
#
# Depends:
#  gen_puppet
#
class gen_php5::curl {
  include gen_php5::common
  include gen_base::libcurl3

  kpackage { "php5-curl":
    ensure => latest,
  }
}
