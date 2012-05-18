# Author: Kumina bv <support@kumina.nl>

# Class: gen_proftpd
#
# Actions:
#  Set up proftpd.
#
# Depends:
#  gen_puppet
#
class gen_proftpd {
  kservice { "proftpd":
    package    => "proftpd-basic",
    pensure    => latest,
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    hasreload  => true,
  }
}

# Class: gen_proftpd::mysql
#
# Actions:
#  Set up MySQL for ProFtpd.
#
# Depends:
#  gen_puppet
#
class gen_proftpd::mysql {
  package { "proftpd-mod-mysql":
    ensure => latest,
  }
}
