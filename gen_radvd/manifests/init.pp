# Author: Kumina bv <support@kumina.nl>

# Class: gen_radvd
#
# Actions:
#  Install radvd.
#
# Depends:
#  gen_puppet
#
class gen_radvd {
  kservice { 'radvd':; }

  concat { '/etc/radvd.conf':
    notify  => Exec['reload-radvd'],
    require => Package['radvd'];
  }
}

#
# Define: gen_radvd::prefix
#
# Actions:
#  Setup a Router Advertisment for a prefix on an interface.
#
# Parameters:
#  interface:
#   The interface the advertisment should be sent out on.
#  prefix:
#   The IPv6 prefix (in the form of 1:2:2:3::/64) to be announced on this interface
#
# Depends:
#  gen_radvd
#
define gen_radvd::prefix ($interface, $prefix) {
  include gen_radvd
  concat::add_content { "radvd config for ${name}":
    content => template('gen_radvd/config'),
    target  => '/etc/radvd.conf';
  }
}
