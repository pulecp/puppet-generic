# Author: Kumina bv <support@kumina.nl>
#
# A huge amount of logic and code is copied from Puppetlabs' puppet-postgresql module, so kudos to them!
# https://github.com/puppetlabs/puppet-postgresql/
#

# Class: gen_postgresql::client
#
# Actions: Setup required client packages.
#
class gen_postgresql::client {
  if $lsbdistcodename == 'wheezy' {
    package { 'postgresql-client':; }
  } else {
    fail('Only tested on Wheezy, check gen_postgresql::client.')
  }
}

# Class: gen_postgresql::server
#
# Actions:
#  Setup PostgreSQL server.
#
# Parameters:
#  datadir: Location where to put the data files. Optional.
#  version: The version of PostgreSQL we want to install
#
# Depends:
#  gen_puppet
#
class gen_postgresql::server ($datadir=false, $version) {
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

  if versioncmp($version,'8.4') == 0 {
    # Not available in Wheezy
    if $lsbdistcodename == 'wheezy' {
      fail('Wheezy does not support PostgreSQL 8.4.')
    }

    package { "postgresql-${version}":
      require => $datadir ? {
        false   => Package["libpq5"],
        default => [Package["libpq5"],Exec["Create datadir before we install PostgreSQL, if needed"]],
      },
      alias   => "postgresql-server";
    }
  } elsif versioncmp($version, '9.1') == 0 {
    # Use backports on Squeeze
    if $lsbdistcodename == 'squeeze' {
      gen_apt::preference { ["postgresql-${version}","libpq5","postgresql-client-9.1","postgresql-common","postgresql-client-common"]:; }
    }

    package {
      "postgresql-${version}":
        require => $datadir ? {
          false   => Package["libpq5"],
          default => [Package["libpq5"],Exec["Create datadir before we install PostgreSQL, if needed"]],
        },
        alias   => "postgresql-server";
      "postgresql-client-${version}":
        require => Package["postgresql-common","postgresql-client-common"],
        notify  => Package["postgresql-server"];
      "postgresql-common":
        require => Package["postgresql-client-common"],
        notify  => Package["postgresql-server"];
      "postgresql-client-common":;
    }
  } else {
    fail("Unknown PostgreSQL version ${version}. Please check the puppet code in gen_postgresql.")
  }

  kservice { "postgresql":
    hasrestart => true,
    hasstatus  => true,
    require    => Package["postgresql-server"];
  }

  user { "postgres":
    require => Package["postgresql-server"];
  }

  group { "postgres":
    require => Package["postgresql-server"];
  }
}

# Define: gen_postgresql::server::db
#
# Actions: Create a PostgreSQL database, if it doesn't exist.
#
# Parameters:
#  name: Name of the database.
#  use_utf8: Use UTF8 encoding.
#  owner: A specific user should be owner. An owner can create tables and everything without additional required permissions.
#
define gen_postgresql::server::db ($use_utf8=false, $owner=false) {
  if ! ($name in split($psql_dbs,';')) {
    # Encoding set to utf8
    if $use_utf8 { $enc = "-E UTF-8" } else { $enc = "" }

    # Set the owner, if applicable
    if $owner { $use_owner = "-O ${owner}" } else { $use_owner = "" }

    exec { "Create db ${name} in PostgreSQL":
      command => "/usr/bin/sudo -u postgres /usr/bin/createdb ${enc} ${use_owner} ${name} 'Created by puppet.'",
      require => $owner ? {
        false   => Package["postgresql-server"],
        default => [Package["postgresql-server"],Gen_postgresql::Server::User[$owner]],
      };
    }
  }
}

# Define: gen_postgresql::server::user
#
# Actions: Create a PostgreSQL user, if it doesn't exist.
#
# Parameters:
#  name: Name of the user.
#  password: The password for this user.
#
define gen_postgresql::server::user (password) {
  if ! ($name in split($psql_users,';')) {
    exec { "Create user ${name} in PostgreSQL":
      command => "/usr/bin/sudo -u postgres psql -c \"CREATE USER ${name} WITH PASSWORD '${password}' NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;\"",
      require => Package["postgresql-server"];
    }
    # This doesn't execute for some reason...
    #postgresql_psql { "CREATE USER ${name} WITH PASSWORD '${password}' NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN":; }
  }
}

# Define: gen_postgresql::server::grant_on_database
#
# Actions: Setup permissions on a database (schema) for a specific user that's not the owner.
#
# Parameters:
#  name: Something unique, but it's not used anywhere.
#  user: The user this change should be about.
#  db: The database this change should be about.
#  permissions: The permissions to grant to the user on this database. Can be one of 'CREATE', 'CONNECT', 'TEMPORARY' or 'TEMP' (alias for 'TEMPORARY'). Can be multiple,
#               if you delimit them with spaces.
#
define gen_postgresql::server::grant_on_database () {
  # XXX
  fail('Not yet implemented.')
}
