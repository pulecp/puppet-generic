# Author: Kumina bv <support@kumina.nl>

# Class: webalizer
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class webalizer {
  package { "webalizer":
    ensure => present,
  }

  file { "/etc/cron.daily/webalizer":
    owner => "root",
    group => "root",
    mode => 755,
    source => "puppet://puppet/webalizer/cron.daily/webalizer",
    require => Package["webalizer"],
  }
}
