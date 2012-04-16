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
}

define gen_postgresql::server::db ($use_utf8=false, $owner=false) {
  if ! ($name in split($psql_dbs,';')) {
    # Encoding set to utf8
    if $use_utf8 { $enc = "-E UTF-8" } else { $enc = "" }

    # Set the owner, if applicable
    if $owner { $use_owner = "-O ${owner}" } else { $use_owner = "" }

    exec { "Create db ${name} in PostgreSQL":
      command => "/usr/bin/sudo -u postgres /usr/bin/createdb ${enc} ${use_owner} ${name} 'Created by puppet.'",
      require => $owner ? {
        false   => undef,
        default => Gen_postgresql::Server::User[$owner],
      };
    }
  }
}

define gen_postgresql::server::user (password) {
  if ! ($name in split($psql_users,';')) {
    exec { "Create user ${name} in PostgreSQL":
      command => "/usr/bin/sudo -u postgres /usr/bin/psql -c \"CREATE USER ${name} WITH PASSWORD '${password}' NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;\"",
    }
  }
}
