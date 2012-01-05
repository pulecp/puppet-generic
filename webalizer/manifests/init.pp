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

  kfile { "/etc/cron.daily/webalizer":
    mode    => 755,
    source  => "webalizer/cron.daily/webalizer";
  }
}
