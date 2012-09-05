# Author: Kumina bv <support@kumina.nl>

# Class: gen_clamav
#
# Actions:
#  Basic ClamAV installation
#
# Depends:
#  gen_puppet
#
class gen_clamav {
  package { ['clamav-base', 'libclamav6']:
    ensure => latest;
  }

  kservice { 'clamav-daemon':
    pensure => latest,
    pattern => '/usr/sbin/clamd';
  }

  kservice { 'clamav-freshclam':
    pensure => latest,
    pattern => '/usr/bin/freshclam';
  }
}
