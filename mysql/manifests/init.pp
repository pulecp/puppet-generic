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
class mysql::server {
  include mysql

  case $lsbdistcodename {
    "lenny":   { $mysqlserver = "mysql-server-5.0" }
    "squeeze": { $mysqlserver = "mysql-server-5.1" }
  }

  kpackage { $mysqlserver:
    alias => "mysql-server";
  }

  service { "mysql":
    hasrestart => true,
    hasstatus  => true;
  }

  exec { "reload-mysql":
    command     => "/etc/init.d/mysql reload",
    refreshonly => true;
  }

  kfile {
    "/etc/mysql/my.cnf":
      content => template("mysql/my.cnf"),
      mode    => 0640,
      require => Package["${mysqlserver}"];
    "/etc/mysql/conf.d":
      ensure  => directory,
      mode    => 0750,
      require => Package["${mysqlserver}"];
    "/etc/mysql/conf.d/binary-logging.cnf":
      content => template("mysql/binary-logging.cnf"),
      notify  => Service["mysql"];
    "/etc/mysql/conf.d/file-per-table.cnf":
      content => "[mysqld]\ninnodb_file_per_table\n",
      notify  => Service["mysql"];
  }

  if ($mysql_serverid) {
    kfile { "/etc/mysql/conf.d/server-id.cnf":
      content => "[mysqld]\nserver-id = $mysql_serverid\n",
      notify  => Service["mysql"];
    }
  }

  define db ($use_utf8=false) {
    exec { "create-${name}-db":
      unless  => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf ${name}",
      command => $use_utf8 ? { 
        false   => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"create database ${name};\"",
        default => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"create database ${name} CHARACTER SET utf8 COLLATE utf8_general_ci;\"",
      },
      require => Service["mysql"];
    }
  }

  define grant($user, $db, $password=false, $hostname="localhost", $permissions="all") {
    if $password {
      exec { "grant_${user}_${db}_${hostname}":
        unless  => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"show grants for '${user}'@'${hostname}';\" | grep -i \"${permissions}\" | grep -q -e \"ON \`${db}\`\.\*\" -e \"ON \*\.\*\"",
        command => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"grant ${permissions} on ${db}.* to '${user}'@'${hostname}' identified by '${password}';\"",
        require => $db ? {
          "*"     => Service["mysql"],
          default => [Service["mysql"], Exec["create-${db}-db"]],
        };
      }
    } else {
      exec { "grant_${user}_${db}_${hostname}":
        unless  => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"show grants for '${user}'@'${hostname}';\" | grep -i \"${permissions}\" | grep -q -e 'ON \`${db}\`\.\*' -e 'ON \*\.\*'",
        command => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"grant ${permissions} on ${db}.* to '${user}'@'${hostname}';\"",
        require => $db ? {
          "*"     => Service["mysql"],
          default => [Service["mysql"], Exec["create-${db}-db"]],
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
  kfile {
    "/etc/mysql/conf.d/slave.cnf":
      content => template("mysql/slave.cnf"),
      notify  => Service["mysql"];
    # Modified init script which waits for temporary tables to close.
    "/etc/init.d/mysql":
      source  => "puppet://puppet/mysql/init.d/mysql",
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

  kfile {
    "/etc/mysql/conf.d/slave-delayed.cnf":
      source  => "puppet://puppet/mysql/mysql/slave-delayed.cnf",
      notify  => Service["mysql"];
    "/etc/default/mk-slave-delay":
      content => template("mysql/default/mk-slave-delay");
    "/etc/init.d/mk-slave-delay":
      mode    => 755,
      source  => "puppet://puppet/mysql/init.d/mk-slave-delay",
      require => [File["/etc/default/mk-slave-delay"],Package["maatkit"]];
    "/etc/logrotate.d/mk-slave-delay":
      source  => "puppet://puppet/mysql/logrotate.d/mk-slave-delay",
      require => Package["maatkit"];
  }

  kpackage { "maatkit":; }
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
  kpackage { "libmysql-java":; }
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

