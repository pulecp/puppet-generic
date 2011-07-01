# Author: Kumina bv <support@kumina.nl>

# Class: mysql::server
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class mysql::server {
	case $lsbdistcodename {
		"lenny":   { $mysqlserver = "mysql-server-5.0" }
		"squeeze": { $mysqlserver = "mysql-server-5.1" }
	}

	kpackage { $mysqlserver:
		alias => "mysql-server",
	}

	service { "mysql":
		hasrestart => true,
		hasstatus => true,
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
	}

	if ($mysql_serverid) {
		kfile { "/etc/mysql/conf.d/server-id.cnf":
			content => "[mysqld]\nserver-id = $mysql_serverid\n",
			notify  => Service["mysql"];
		}
	}

	if ($mysql_bindaddress) {
		file { "/etc/mysql/conf.d/bind-address.cnf":
			mode => 644,
			owner => "root",
			group => "root",
			content => "[mysqld]\nbind-address = $mysql_bindaddress\n",
			notify => Service["mysql"],
		}
	}
	file { "/etc/mysql/conf.d/binary-logging.cnf":
		mode => 644,
		owner => "root",
		group => "root",
		content => template("mysql/binary-logging.cnf"),
		notify => Service["mysql"],
	}

	file { "/etc/mysql/conf.d/file-per-table.cnf":
		mode    => 644,
		owner   => "root",
		group   => "root",
		content => "[mysqld]\ninnodb_file_per_table\n",
		notify  => Service["mysql"],
	}

	define db {
		exec { "create-${name}-db":
			unless  => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf ${name}",
			command => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"create database ${name};\"",
			require => Service["mysql"];
		}
	}

	define grant($user, $db, $password=false, $hostname="localhost", $permissions="all") {
		if $password {
			exec { "grant-${user}-${db}":
				unless  => "/usr/bin/mysql -u ${user} -p${password} ${db}",
				command => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"grant ${permissions} on ${db}.* to '${user}'@'${hostname}' identified by '${password}';\"",
				require => $db ? {
					"*"     => Service["mysql"],
					default => [Service["mysql"], Exec["create-${db}-db"]],
				};
			}
		} else {
			exec { "grant-${user}-${db}":
				unless  => "/usr/bin/mysql -u ${user} ${db}",
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
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class mysql::slave inherits mysql::server {
	file { "/etc/mysql/conf.d/slave.cnf":
		owner => "root",
		group => "root",
		mode => 644,
		content => template("mysql/slave.cnf"),
		notify => Service["mysql"],
	}

	# Modified init script which waits for temporary tables to close.
	file { "/etc/init.d/mysql":
		source => "puppet://puppet/mysql/init.d/mysql",
		owner => "root",
		group => "root",
		mode => 755,
		require => Package["$mysqlserver"];
	}
}

# Class: mysql::slave::delayed
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class mysql::slave::delayed inherits mysql::slave {
	service { "mk-slave-delay":
		enable => true,
		require => File["/etc/init.d/mk-slave-delay"],
	}

	file {
		"/etc/mysql/conf.d/slave-delayed.cnf":
			source => "puppet://puppet/mysql/mysql/slave-delayed.cnf",
			owner => "root",
			group => "root",
			mode => 644,
			notify => Service["mysql"];
		"/etc/default/mk-slave-delay":
			owner => "root",
			group => "root",
			mode => 644,
			content => template("mysql/default/mk-slave-delay");
		"/etc/init.d/mk-slave-delay":
			owner => "root",
			group => "root",
			mode => 755,
			source => "puppet://puppet/mysql/init.d/mk-slave-delay",
			require => [File["/etc/default/mk-slave-delay"],
				    Package["maatkit"]];
		"/etc/logrotate.d/mk-slave-delay":
			source => "puppet://puppet/mysql/logrotate.d/mk-slave-delay",
			owner => "root",
			group => "root",
			mode => 644,
			require => Package["maatkit"];
	}

	package { "maatkit":
		ensure => installed,
	}
}

# Class: mysql::munin
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class mysql::munin {
	munin::client::plugin { ["mysql_bytes","mysql_innodb","mysql_queries","mysql_slowqueries","mysql_threads"]:; }
}


# Define: mysql::user
#
# Parameters:
#	password
#		Undocumented
#	hostname
#		Undocumented
#	user
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define mysql::user($user, $password=false, $hostname="localhost") {
	if $password {
		exec { "create-${user}${hostname}":
			onlyif  => "/usr/bin/pgrep mysqld && ! /usr/bin/mysql -u ${user} -p${password}",
			command => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"create user '${user}'@'${hostname}' identified by '${password}';\"",
			require => Service["mysql"];
		}
	} else {
		exec { "create-${user}${hostname}":
			onlyif  => "/usr/bin/pgrep mysqld && ! /usr/bin/mysql -u ${user}",
			command => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -e \"create user '${user}'@'${hostname}';\"",
			require => Service["mysql"];
		}
	}
}
