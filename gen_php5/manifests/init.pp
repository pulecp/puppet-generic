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
  package { "php5-common":
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
    package { "libapache2-mod-php5":
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

  package { "php5-cgi":
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

  package { "php5-cli":
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
class gen_php5::apc ($shm_size = 64, $ttl = 3600) {
  include gen_php5::common

  package { "php-apc":
    ensure => latest,
  }

  gen_php5::common::config {
    'apc.mmap_file_mask': value => '/apc.shm.XXXXXX';
    'apc.shm_size':       value => "${shm_size}";
    'apc.ttl':            value => "${ttl}";
    'apc.filters':        value => 'wp-cache-config';
  }

  $shm_size_digits = regsubst($shm_size,'([0-9]+).*', '\1')
  # TODO this only works if the value is in MBs...
  $shm_size_in_bytes = regsubst($shm_size_digits,'(\d+)', '\1') * 1024 * 1024

  line { "Increase shared mem setting in kernel":
    file    => "/etc/sysctl.conf",
    content => "kernel.shmmax=${shm_size_in_bytes}",
    notify  => Exec["reload-sysctl"];
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

  package { "php-pear":
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
class gen_php5::mysql ($httpd_type="apache2"){
  include gen_php5::common

  package { "php5-mysql":
    ensure => latest,
    notify => Exec["reload-${httpd_type}"];
  }
}

# Class: gen_php5::gd
#
# Actions:
#  Install GD for PHP5.
#
# Depends:
#  gen_puppet
#
class gen_php5::gd ($httpd_type="apache2"){
  include gen_php5::common

  package { "php5-gd":
    ensure => latest,
    notify => Exec["reload-${httpd_type}"];
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

  package { "php5-curl":
    ensure => latest,
  }
}

# Class: gen_php5::memcache
#
# Actions:
#  Install memcache extensions for PHP5.
#
# Depends:
#  gen_puppet
#
class gen_php5::memcache {
  include gen_php5::common

  package { "php5-memcache":
    ensure => latest,
  }
}

# Class: gen_php5::smarty
#
# Actions:
#  Install smarty extensions for PHP5.
#
# Depends:
#  gen_puppet
#
class gen_php5::smarty {
  package { "smarty":
    ensure => latest,
  }
}

# Class: gen_php5::xsl
#
# Actions:
#  Install xsl extensions for PHP5.
#
# Depends:
#  gen_puppet
#
class gen_php5::xsl {
  include gen_base::libxslt1_1

  package { "php5-xsl":
    ensure => latest,
  }
}

# Class: gen_php5::imap
#
# Actions:
#  Install imap extension for PHP5.
#
# Depends:
#  -
#
class gen_php5::imap {
  package { "php5-imap":
    ensure => latest,
  }
}

# Class: gen_php5::xmlrpc
#
# Actions:
#  Install xmlrpc extension for PHP5.
#
# Depends:
#  -
#
class gen_php5::xmlrpc ($httpd_type="apache2") {
  package { "php5-xmlrpc":
    ensure => latest,
    notify => Exec["reload-${httpd_type}"];
  }
}

# Define: gen_php5::common::config
#
# Actions:
#  Settings for PHP5, globally.
# Parameters:
#  ensure      standard puppet ensure
#  variable    PHP settings variable, defaults to resource name
#  value       PHP settings value
#
# Depends:
#  gen_puppet
#
define gen_php5::common::config ($ensure='present', $value=false, $variable=false) {
  if ! defined(File["/etc/php5/conf.d/set-via-puppet.ini"]) {
    file { "/etc/php5/conf.d/set-via-puppet.ini":
      require => Package["php5-common"],
      content => "[PHP]\n",
      replace => false,
    }
  }

  if ! $value {
    if $ensure == 'present' {
      fail("Gen_php5::Common::Config[${name}]: no value given")
    }
  } else {
    $real_value = $value
  }

  if ! $variable {
    $real_var = $name
  } else {
    $real_var = $variable
  }

  kaugeas { "PHP5 setting ${real_var}":
    file    => "/etc/php5/conf.d/set-via-puppet.ini",
    require => File["/etc/php5/conf.d/set-via-puppet.ini"],
    lens    => "PHP.lns",
    changes => $ensure ? {
      'present' => "set PHP/${real_var} '${real_value}'",
      default   => "rm PHP/${real_var}",
    },
    notify  => Exec['reload-apache2'];
  }
}
