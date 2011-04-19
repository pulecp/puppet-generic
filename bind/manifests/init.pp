class bind {
	package { "bind9":
		ensure => installed,
	}

	kfile {
		"/etc/bind/named.conf":
			require => Package["bind9"];
		"/etc/bind/named.conf.options":
			source => "bind/named.conf.options",
			require => Package["bind9"];
		"/etc/bind/named.conf.local":
			source => "bind/named.conf.local",
			require => Package["bind9"];
		"/etc/bind/zones":
			ensure  => directory,
			group   => "bind",
			require => Package["bind9"];
		"/etc/bind/create_zones_conf":
			source => "bind/create_zones_conf",
			mode => 755,
			require => Package["bind9"];
		"/etc/bind/Makefile":
			source => "bind/Makefile",
			require => Package["bind9"];
	}

	service { "bind9":
		ensure => running,
		pattern => "/usr/sbin/named",
		subscribe => [File["/etc/bind/named.conf.local"],
		              File["/etc/bind/named.conf.options"],
                              File["/etc/bind/named.conf"],
			      Exec["update-zone-conf"]],
	}

	exec { "update-zone-conf":
		command => "/bin/sh -c 'cd /etc/bind && make'",
		refreshonly => true,
		require => [File["/etc/bind/zones"],
		            File["/etc/bind/create_zones_conf"],
			    File["/etc/bind/Makefile"],
			    Package["make"]],
	}

	define zone_alias ($target) {
		kfile { "/etc/bind/zones/$name":
			ensure => link,
			target => "/etc/bind/zones/$target",
			notify => Exec["update-zone-conf"],
			require => File["/etc/bind/zones/$target"],
		}
	}

	define zone ($source, $aliases=false) {
		kfile { "/etc/bind/zones/$name":
			owner => root,
			group => root,
			source => $source,
			notify => Exec["update-zone-conf"],
		}

		if $aliases {
			zone_alias { $aliases:
				target => $name,
			}
		}
	}
}
