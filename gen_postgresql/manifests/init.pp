# Author: Kumina bv <support@kumina.nl>

# Class: gen_postgresql
#
# Actions:
#  Stuff.
#
# Depends:
#  gen_puppet
#
class gen_postgresql {
}

# Class: gen_postgresql::server
#
# Actions:
#  Setup PostgreSQL server.
#
# Parameters:
#  datadir: Location where to put the data files. Optional.
#
# Depends:
#  gen_puppet
#
class gen_postgresql::server ($datadir=false, $version="8.4") {
  include gen_postgresql
  include gen_base::libpq5

  if $datadir {
    exec { "Create datadir before we install PostgreSQL, if needed":
      command => "/bin/mkdir -p ${datadir}",
      creates => $datadir,
    }

    file {
      $datadir:
        ensure => directory,
        mode   => 770,
        owner  => "postgres",
        group  => "postgres";
    }
  }

  kpackage { "postgresql-${version}":
    require => $datadir ? {
      false   => Kpackage["libpq5"],
      default => [Kpackage["libpq5"],Exec["Create datadir before we install MySQL, if needed"]],
    },
    alias   => "postgresql-server";
  }

  service { "postgresql":
    hasrestart => true,
    hasstatus  => true,
    require    => Kpackage["postgresql-server"];
  }

  user { "postgres":
    require => Kpackage["postgresql-server"];
  }

  group { "postgres":
    require => Kpackage["postgresql-server"];
  }

  exec { "reload-postgresql":
    command     => "/etc/init.d/postgresql reload",
    refreshonly => true,
    require     => Kpackage["postgresql-server"];
  }

  define db ($use_utf8=false) {
  }

  define grant($user=false, $db=false, $password=false, $hostname="localhost", $permissions="all", $grant_option=false) {
  }
}


# Class: postgresql::munin
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class postgresql::munin {
  #munin::client::plugin { ["postgresql_bytes","postgresql_innodb","postgresql_queries","postgresql_slowqueries","postgresql_threads"]:; }
}

# Class: postgresql::backport_pinning
#
# Action:
#  Setup pinning in apt for PostgreSQL from backports, if needed.
#
# Depends:
#  gen_apt
