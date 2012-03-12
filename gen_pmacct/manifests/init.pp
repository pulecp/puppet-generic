# Author: Kumina bv <support@kumina.nl>

# Class: gen_pmacct
#
# Actions:
#  Sets up pmacct
#
# Depends:
#  gen_puppet
#
class gen_pmacct {
  kservice { "pmacct":; }
}

# Define: gen_pmacct::config
#
# Actions:
#  Setup specific aggregates for pmacctd. Multiple aggregates are supported with additional
#  gen_pmacct::config resources within puppet.
#
# Parameters:
#  name
#   Name of the aggregate. Used to identify it.
#  plugins
#   Plugins to use for this resource. Check the pmacct docs for supported plugins.
#
# Depends:
#  gen_pmacct
#  gen_puppet
#
define gen_pmacct::config ($aggregates, $plugins, $sql_host, $sql_db, $sql_user, $sql_passwd, $sql_history, $sql_history_roundoff, $sql_refresh_time, $sql_dont_try_update) {
  include gen_pmacct

  file { "/etc/pmacct/pmacctd.${name}.conf":
    content => template("gen_pmacct/pmacct.conf"),
    notify  => Service["pmacct"],
  }
}
