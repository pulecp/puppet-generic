# Author: Kumina bv <support@kumina.nl>

# Class: mysql
#
# Actions:
#  Make an exec available that flushes privileges.
#
# Depends:
#  gen_puppet
#
class mysql {
  exec { "MySQL flush privileges":
    command     => "/usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf flush-privileges",
    refreshonly => true,
    require     => Service["mysql"],
  }
}

# Class: mysql::server
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class mysql::server ($datadir=false) {
  include mysql

  case $lsbdistcodename {
    "lenny":   { $mysqlserver = "mysql-server-5.0" }
    "squeeze": { $mysqlserver = "mysql-server-5.1" }
  }

  if $datadir {
    exec { "Create datadir before we install MySQL, if needed":
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
        notify  => Package[$mysqlserver];
    }
  }

  package { $mysqlserver:
    require => $datadir ? {
      false   => undef,
      default => Exec["Create datadir before we install MySQL, if needed"],
    },
    alias   => "mysql-server";
  }

  service { "mysql":
    hasrestart => true,
    hasstatus  => true,
    require    => Package[$mysqlserver];
  }

  user { "mysql":
    require => Package[$mysqlserver];
  }

  group { "mysql":
    require => Package[$mysqlserver];
  }

  exec { "reload-mysql":
    command     => "/etc/init.d/mysql reload",
    refreshonly => true,
    require     => Package[$mysqlserver];
  }

  file {
    "/etc/mysql":
      ensure  => directory,
      notify  => Package[$mysqlserver];
    "/etc/mysql/my.cnf":
      content => template("mysql/my.cnf"),
      mode    => 0644,
      require => Package["${mysqlserver}"];
    "/etc/mysql/conf.d":
      ensure  => directory,
      mode    => 0755,
      notify  => Package["${mysqlserver}"];
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
      notify  => Service["mysql"];
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
        require => Service["mysql"];
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
      fail("String '$real_user}' is too long for user name (should be no longer than 16)")
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

    $cmd_check_grant_option ? $grant_option {
      true  => "-e \"${cmd_grant_option}\"",
      false => '',
    }


    $cmd_unless = "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"show grants for '${real_user}'@'${hostname}';\" | grep -q -i -e \"${permissions}\" -e \"ON \\`${real_db}\\`.*\" -e \"ON *.*\" ${cmd_check_grant_option}",

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
          "*"     => Service["mysql"],
          default => [Service["mysql"], Exec["create-${real_db}-db"]],
        };
      }
    }
  }
}

# Class: mysql::slave
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class mysql::slave inherits mysql::server {
  file {
    "/etc/mysql/conf.d/slave.cnf":
      content => template("mysql/slave.cnf"),
      notify  => Service["mysql"];
    # Modified init script which waits for temporary tables to close.
    "/etc/init.d/mysql":
      content  => template("mysql/init.d/mysql"),
      mode    => 755,
      require => Package["$mysqlserver"];
  }
}

# Class: mysql::slave::delayed
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class mysql::slave::delayed inherits mysql::slave {
  service { "mk-slave-delay":
    enable  => true,
    require => File["/etc/init.d/mk-slave-delay"],
  }

  file {
    "/etc/mysql/conf.d/slave-delayed.cnf":
      content => template("mysql/mysql/slave-delayed.cnf"),
      notify  => Service["mysql"];
    "/etc/default/mk-slave-delay":
      content => template("mysql/default/mk-slave-delay");
    "/etc/init.d/mk-slave-delay":
      mode    => 755,
      content => template("mysql/init.d/mk-slave-delay"),
      require => [File["/etc/default/mk-slave-delay"],Package["maatkit"]];
    "/etc/logrotate.d/mk-slave-delay":
      content => template("mysql/logrotate.d/mk-slave-delay"),
      require => Package["maatkit"];
  }

  package { "maatkit":; }
}

# Class: mysql::munin
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class mysql::munin {
  munin::client::plugin { ["mysql_bytes","mysql_innodb","mysql_queries","mysql_slowqueries","mysql_threads"]:; }
}


# Define: mysql::server::user
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
define mysql::user($user, $password=false, $hostname="localhost") {
  exec { "create MySQL user ${user} from ${hostname}":
    onlyif  => "/usr/bin/pgrep mysqld && /usr/bin/test `/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf --skip-column-names -B -e \"select count(*) from mysql.user where User='${user}' and Host='${hostname}'\"` -eq 0",
    command => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"create user '${user}'@'${hostname}';\"",
    notify  => Exec["MySQL flush privileges"],
    require => Service["mysql"];
  }

  if $password {
    exec { "create ${user} from ${hostname} with a password":
      onlyif  => "/usr/bin/test `mysql --defaults-file=/etc/mysql/debian.cnf --skip-column-names -B -e \"select count(*) from mysql.user where User='${user}' and Host='${hostname}' and Password=PASSWORD('${password}')\" -eq 0",
      command => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"update mysql.user set Password = PASSWORD('${password}') where User = '${user}' and Host = '${hostname}';\"",
      notify  => Exec["MySQL flush privileges"],
      require => Exec["create MySQL user ${user} from ${hostname}"];
    }
  }
}

class mysql::java {
  package { "libmysql-java":; }
}

define mysql::server::permissions ($user, $db, $hostname="localhost", $permissions="all") {
  # $name is not used, make it whatever you like
  if "select" in $permissions or $permissions == "all" {
    exec { "set select permission on $db for $user at $hostname":
      onlyif  => "/usr/bin/pgrep mysqld && /usr/bin/test `/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf --skip-column-names -B -e \"select count(*) from mysql.user where User='${user}' and Host='${hostname}'\"` -eq 0",
      command => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"grant select on ${db}.* to '${user}'@'{hostname}';\"",
      require => Exec["create MySQL user ${user} from ${hostname}"],
      notify  => Exec["MySQL flush privileges"],
    }
  }
}

