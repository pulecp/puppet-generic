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
  kpackage { "webalizer":; }

  file { "/etc/cron.daily/webalizer":
    mode    => 755,
    content => template("webalizer/webalizer");
  }
}
