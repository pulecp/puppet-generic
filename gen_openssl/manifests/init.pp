# Author: Kumina bv <support@kumina.nl>

# Class: gen_openssl::common
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class gen_openssl::common {
  package { "openssl":; }

  if $lsbdistcodename == 'wheezy' {
    package { "libssl1.0.0":; }
  } else {
    package { "libssl0.9.8":; }
  }

  file { "/etc/ssl/certs":
    recurse  => true,
    require  => Package["openssl"];
  }
}

# Class: gen_openssl::ca
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class gen_openssl::ca {
  include gen_openssl::common

  file {
    "/etc/ssl/newcerts":
      ensure  => directory,
      mode    => 750,
      require => Package["openssl"];
    "/etc/ssl/requests":
      ensure  => directory,
      mode    => 750,
      require => Package["openssl"];
    "/etc/ssl/Makefile":
      content => template("gen_openssl/Makefile"),
      require => Package["openssl"];
  }
}

# Define: gen_openssl::create_ca
#
# Parameters:
#  length
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define gen_openssl::create_ca ($length = 4096) {
  exec { "create ca secret key ${name}":
    command  => "/usr/bin/openssl genrsa -out '${name}' ${length}",
    creates  => "${name}",
    requires => Package["openssl"],
  }
}

# Define: gen_openssl::create_ca_csr
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define gen_openssl::create_ca_csr () {
  # Bother, needs a config file for the values? Silly.
}
