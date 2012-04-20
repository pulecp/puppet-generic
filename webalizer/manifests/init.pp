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
  package { "webalizer":; }

  file { "/etc/cron.daily/webalizer":
    mode    => 755,
    content => template("webalizer/webalizer");
  }
}
