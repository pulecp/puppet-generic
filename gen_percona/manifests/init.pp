# Author: Kumina bv <support@kumina.nl>

# Class: gen_percona
#
# Actions:
#  Make an exec available that flushes privileges.
#
# Depends:
#  gen_puppet
#
class gen_percona {
  exec { "Percona flush privileges":
    command     => "/usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf flush-privileges",
    refreshonly => true,
    require     => Service["mysql"],
  }

  gen_apt::key { 'CD2EFD2A':
    content => template('gen_percona/CD2EFD2A'),
  }

  gen_apt::source { "percona":
    uri          => "http://repo.percona.com/apt",
    distribution => $lsbdistcodename,
    components   => ['main'],
    key          => 'CD2EFD2A',
  }
}

# Class: percona::server
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class gen_percona::server ($datadir=false,$version=false) {
  include gen_percona

  if ! $version {
    case $lsbdistcodename {
      "squeeze": { $perconaserver = "percona-server-server-5.1" }
      "wheezy":  { $perconaserver = "percona-server-server-5.5" }
    }
  } else {
    $perconaserver = "percona-server-server-${version}"
  }

  if $datadir {
    exec { "Create datadir before we install Percona, if needed":
      command => "/bin/mkdir -p ${datadir}",
      creates => $datadir,
    }

    file {
      $datadir:
        ensure => directory,
        mode   => 770,
        owner  => "mysql",
        group  => "mysql";
      "/etc/mysql/conf.d/datadir.cnf":
        content => "[mysqld]\ndatadir = ${datadir}\n",
        notify  => Package[$perconaserver];
    }
  }

  # Package needs to be on hold, otherwise you could inadvertantly install something like mysql-common, which will
  # remove percona from the server...
  package { $perconaserver:
    ensure  => installed,
    require => $datadir ? {
      false   => undef,
      default => Exec["Create datadir before we install Percona, if needed"],
    },
    alias   => "percona-server";
  }

  # The Percona initscript is called mysql
  service { "mysql":
    alias      => 'percona',
    hasrestart => true,
    hasstatus  => true,
    require    => Package[$perconaserver];
  }

  user { "mysql":
    require => Package[$perconaserver];
  }

  group { "mysql":
    require => Package[$perconaserver];
  }

  exec { "reload-percona":
    command     => "/etc/init.d/mysql reload",
    alias       => "reload-mysql",
    refreshonly => true,
    require     => Package[$perconaserver];
  }

  file {
    "/etc/mysql":
      ensure  => directory,
      notify  => Package[$perconaserver];
    "/etc/mysql/my.cnf":
      content => template("mysql/my.cnf"),
      mode    => 0644,
      require => Package[$perconaserver];
    "/etc/mysql/conf.d":
      ensure  => directory,
      mode    => 0755,
      notify  => Package[$perconaserver];
    "/etc/mysql/conf.d/binary-logging.cnf":
      content => template("mysql/binary-logging.cnf"),
      notify  => Service["mysql"];
    "/etc/mysql/conf.d/file-per-table.cnf":
      content => "[mysqld]\ninnodb_file_per_table\n",
      notify  => Service["mysql"];
  }

  if ($mysql_serverid) {
    file { "/etc/mysql/conf.d/server-id.cnf":
      content => "[mysqld]\nserver-id = $mysql_serverid\n",
      notify  => Service["percona"];
    }
  }

  define db ($use_utf8=false) {
    $db_name = regsubst($name,'^(.*?) (.*)$','\1')

    if ! defined(Exec["create-${db_name}-db"]) {
      exec { "create-${db_name}-db":
        unless  => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf ${db_name}",
        command => $use_utf8 ? {
          false   => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"create database ${db_name};\"",
          default => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"create database ${db_name} CHARACTER SET utf8 COLLATE utf8_general_ci;\"",
        },
        require => Service["percona"];
      }
    }
  }

  define grant($user=false, $db=false, $password=false, $hostname="localhost", $permissions="all", $grant_option=false, $require_ssl=false) {
    if !$user {
      $real_user = regsubst($title, '([a-zA-Z0-9_]+) +on +([*a-zA-Z0-9_]+).*', '\1')
      if ($real_user == $title) {
        fail("Mysql::Server::Grant[\"${title}\"]: please name resource '<user> on <db>.*'")
      }
    }
    else {
      $real_user = $user
    }
    if !$db {
      $real_db = regsubst($title, '([a-zA-Z0-9_]+) +on +([*a-zA-Z0-9_]+).*', '\2')
      if ($real_db == $title) {
        fail("Mysql::Server::Grant[\"${title}\"]: please name resource '<user> on <db>.*'")
      }
    }
    else {
      $real_db = $db
    }
    if inline_template('<%= real_user.length %>') > 16 {
      fail("String '${real_user}' is too long for user name (should be no longer than 16)")
    }

    $cmd_grant_option = $grant_option ? {
      true  => 'WITH GRANT OPTION',
      false => '',
    }

    $cmd_require_ssl = $require_ssl ? {
      true  => 'REQUIRE SSL',
      false => '',
    }

    $cmd_password = $password ? {
      false   => '',
      default => "identified by '${password}'",
    }

    $cmd_check_grant_option =  $grant_option ? {
      true  => "-e \"${cmd_grant_option}\"",
      false => '',
    }

    $cmd_unless = "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"show grants for '${real_user}'@'${hostname}';\" | grep -i -e \"${permissions}\" | grep -q -i -e \"ON \\`${real_db}\\`.*\" -e \"ON *.*\" ${cmd_check_grant_option}"

    if $require_ssl {
      $cmd_check_ssl = " && /usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"show grants for '${real_user}'@'${hostname}';\" | grep -q \"${cmd_require_ssl}\""
    }

    if !defined(Db[$real_db]) and $real_db != "*" {
      db { $real_db:; }
    }

    if !defined(Exec["grant_${real_user}_${real_db}_${hostname}"]) {
      exec { "grant_${real_user}_${real_db}_${hostname}":
        unless  => "${cmd_unless} ${cmd_check_ssl}",
        command => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"grant ${permissions} on ${real_db}.* to '${real_user}'@'${hostname}' ${cmd_password} ${cmd_require_ssl} ${cmd_grant_option};\"",
        require => $real_db ? {
          "*"     => Service["percona"],
          default => [Service["percona"], Exec["create-${real_db}-db"]],
        };
      }
    }
  }
}

# Class: gen_percona::slave
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class gen_percona::slave inherits gen_percona::server {
  file {
    "/etc/percona/conf.d/slave.cnf":
      content => template("percona/slave.cnf"),
      notify  => Service["percona"];
    # Modified init script which waits for temporary tables to close.
    "/etc/init.d/percona":
      content  => template("percona/init.d/percona"),
      mode    => 755,
      require => Package["$perconaserver"];
  }
}

# Class: gen_percona::slave::delayed
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class gen_percona::slave::delayed inherits percona::slave {
  service { "mk-slave-delay":
    enable  => true,
    require => File["/etc/init.d/mk-slave-delay"],
  }

  file {
    "/etc/percona/conf.d/slave-delayed.cnf":
      content => template("percona/percona/slave-delayed.cnf"),
      notify  => Service["percona"];
    "/etc/default/mk-slave-delay":
      content => template("percona/default/mk-slave-delay");
    "/etc/init.d/mk-slave-delay":
      mode    => 755,
      content => template("percona/init.d/mk-slave-delay"),
      require => [File["/etc/default/mk-slave-delay"],Package["maatkit"]];
    "/etc/logrotate.d/mk-slave-delay":
      content => template("percona/logrotate.d/mk-slave-delay"),
      require => Package["maatkit"];
  }

  package { "maatkit":; }

  fail("This class is untested.")
}

# Class: gen_percona::munin
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class gen_percona::munin {
  # This uses MySQL stuff, so create a dependency on that
  include mysql::munin
}


# Define: gen_percona::server::user
#
# Parameters:
#  password
#    Undocumented
#  hostname
#    Undocumented
#  user
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define gen_percona::user($user, $password=false, $hostname="localhost") {
  exec { "create Percona user ${user} from ${hostname}":
    onlyif  => "/usr/bin/pgrep mysqld && /usr/bin/test `/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf --skip-column-names -B -e \"select count(*) from mysql.user where User='${user}' and Host='${hostname}'\"` -eq 0",
    command => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"create user '${user}'@'${hostname}';\"",
    notify  => Exec["Percona flush privileges"],
    require => Service["percona"];
  }

  if $password {
    exec { "create ${user} from ${hostname} with a password":
      onlyif  => "/usr/bin/test `mysql --defaults-file=/etc/mysql/debian.cnf --skip-column-names -B -e \"select count(*) from mysql.user where User='${user}' and Host='${hostname}' and Password=PASSWORD('${password}')\" -eq 0",
      command => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"update mysql.user set Password = PASSWORD('${password}') where User = '${user}' and Host = '${hostname}';\"",
      notify  => Exec["Percona flush privileges"],
      require => Exec["create Percona user ${user} from ${hostname}"];
    }
  }
}

class gen_percona::java {
  # This uses the mysql libs, so we create a dependency to that
  include mysql::java
}

class gen_percona::xtrabackup {
  package { 'percona-xtrabackup':
    ensure => 'latest';
  }
}

define gen_percona::server::permissions ($user, $db, $hostname="localhost", $permissions="all") {
  # $name is not used, make it whatever you like
  if "select" in $permissions or $permissions == "all" {
    exec { "set select permission on $db for $user at $hostname":
      onlyif  => "/usr/bin/pgrep mysqld && /usr/bin/test `/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf --skip-column-names -B -e \"select count(*) from mysql.user where User='${user}' and Host='${hostname}'\"` -eq 0",
      command => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"grant select on ${db}.* to '${user}'@'{hostname}';\"",
      require => Exec["create Percona user ${user} from ${hostname}"],
      notify  => Exec["Percona flush privileges"],
    }
  }
}

