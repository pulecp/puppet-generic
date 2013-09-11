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
  include gen_base::archive_pmacct_data

  kservice { "pmacct":
    hasstatus => false,
  }

  # We do not use the default config from the package. Remove it to avoid mistakes.
  file { "/etc/pmacct/pmacctd.conf":
    ensure => absent,
  }

  kcron { "pmacct-data-archive":
    command => "/usr/bin/archive-pmacct-data",
    mailto  => "root",
    hour    => "1",
    minute  => fqdn_rand( 60 ),
    mday    => "10",
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
define gen_pmacct::config ($aggregates=false, $aggregates_sql=$aggregates, $aggregates_nfprobe=false, $filter=false, $plugins=false, $sql_host=false, $sql_db=false, $sql_user=false, $sql_passwd=false, $sql_history=false, $sql_history_roundoff=false, $sql_refresh_time=false, $sql_dont_try_update=false, $nfprobe_version=9, $nfprobe_receiver=false, $table_per_day=false) {
  include gen_pmacct

  $table_part = regsubst($hostname, '-', '_', 'G')

  file { "/etc/pmacct/pmacctd.${name}.conf":
    content => template("gen_pmacct/pmacct.conf"),
    require => Package["pmacct"],
    notify  => Service["pmacct"],
  }

  if $table_per_day {
    file { '/etc/pmacct/table.mysql':
      notify  => Service["pmacct"],
      content => template('gen_pmacct/table.mysql');
    }

    Kcron <| title == "pmacct-data-archive" |> {
      ensure => absent,
    }
  }

  exec { "/bin/sed -i 's/^\\(INTERFACES=\".*\\)\"$/\\1 ${name}\"/' /etc/default/pmacct":
    unless  => "/bin/sh -c '. /etc/default/pmacct; for i in \$INTERFACES; do if test \$i = ${name}; then exit 0; fi; done; exit 1'",
    require => Package["pmacct"],
    notify  => Service["pmacct"],
  }
}
