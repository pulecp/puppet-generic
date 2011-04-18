class munin::client {
	define plugin($ensure='present', $script_path='/usr/share/munin/plugins', $script=false) {
		if $script {
			$plugin_path = "$script_path/$script"
		} else {
			$plugin_path = "$script_path/$name"
		}

		kfile { "/etc/munin/plugins/$name":
			ensure => $ensure ? {
				'present' => $plugin_path,
				'absent' => 'absent',
			},
			notify => Service["munin-node"],
			require => [Package["munin-node"], File["/usr/local/share/munin/plugins"]],
		}
	}

	define plugin::config($content, $section=false, $ensure='present') {
		kfile { "/etc/munin/plugin-conf.d/$name":
			ensure => $ensure,
			content => $section ? {
				false => "[${name}]\n${content}\n",
				default => "[${section}]\n${content}\n",
			},
			require => Package["munin-node"],
			notify => Service["munin-node"],
		}
	}

	kpackage { "munin-node":; }

	if (($operatingsystem == "Debian") and (versioncmp($lsbdistrelease,"5.0") >= 0)) { # in Lenny and above we have the extra-plugins in a package
		kpackage { "munin-plugins-extra":
			ensure => latest;
		}
	}
	
	# Extra plugins
	kfile {
		"/usr/local/share/munin/plugins":
			recurse => true,
			source => "munin/client/plugins",
			group => "staff",
			mode => 755;
}

	# Munin node configuration
	kfile { "/etc/munin/munin-node.conf":
		content => template("munin/client/munin-node.conf"),
		require => Package["munin-node"],
	}

	service { "munin-node":
		subscribe => File["/etc/munin/munin-node.conf"],
		require => [Package["munin-node"], File["/etc/munin/munin-node.conf"]],
		hasrestart => true,
		ensure => running,
	}

	kfile {
		"/usr/local/share/munin":
			ensure => directory,
			group => "staff";
	}

	kfile { "/usr/local/etc/munin":
		ensure => directory,
		group => "staff",
	}


	# Configs needed for JMX monitoring. Not needed everywhere, but roll out
	# nontheless.
	kfile { "/usr/local/etc/munin/plugins":
		recurse => true,
		source  => "munin/client/configs",
		group   => "staff",
		mode    => 755;
	}
}

class munin::server {
	package { ["munin"]:
		ensure => installed,
	}

	kfile { "/etc/munin/munin.conf":
		source => "munin/server/munin.conf",
		require => Package["munin"],
	}

        # Needed when munin-graph runs as a CGI script
	package { "libdate-manip-perl":
		ensure => installed,
	}

	kfile {
		"/var/log/munin":
                        ensure => directory,
			owner => "munin",
			group => "munin",
			mode => 771;
		"/var/log/munin/munin-graph.log":
			group => "www-data",
			mode => 660;
		"/etc/logrotate.d/munin":
			source => "munin/server/logrotate.d/munin";
	}
}
