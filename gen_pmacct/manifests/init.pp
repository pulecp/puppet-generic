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
  kservice { "pmacct":
    hasstatus => false,
  }

  # We do not use the default config from the package. Remove it to avoid mistakes.
  file { "/etc/pmacct/pmacctd.conf":
    ensure => absent,
  }
}

# Define: gen_pmacct::config
#
# Actions:
#  Setup specific aggregates for pmacctd. Multiple aggregates are supported with additional
#  gen_pmacct::config resources within puppet.
#
# Parameters:
#  name
#   Name of the interface to use. Used to identify it.
#  plugins
#   Plugins to use for this resource. Check the pmacct docs for supported plugins.
#
# Depends:
#  gen_pmacct
#  gen_puppet
#
define gen_pmacct::config ($aggregates, $plugins, $sql_host, $sql_db, $sql_user, $sql_passwd, $sql_history, $sql_history_roundoff, $sql_refresh_time, $sql_dont_try_update) {
  include gen_pmacct

  $table_part = regsubst($hostname, '-', '_', 'G')

  file { "/etc/pmacct/pmacctd.${name}.conf":
    content => template("gen_pmacct/pmacct.conf"),
    require => Kpackage["pmacct"],
    notify  => Service["pmacct"],
  }

  exec { "/bin/sed -i 's/^\\(INTERFACES=\".*\\)\"$/\1 ${name}\"/' /etc/default/pmacct":
    unless  => "/bin/sh -c '. /etc/default/pmacct; for i in \$INTERFACES; do if test \$i = ${name}; then exit 0; fi; done; exit 1'",
    require => Kpackage["pmacct"],
    notify  => Service["pmacct"],
  }
}
