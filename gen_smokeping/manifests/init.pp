# Author: Kumina bv <support@kumina.nl>

# Class: gen_smokeping::server
#
# Actions:
#	Set up a smokeping server
#
# Depends:
#	gen_base
#	gen_puppet
#
class gen_smokeping::server {
	include gen_base::javascript-common
	include gen_base::libsocket6-perl
	include gen_base::libio-socket-inet6-perl

	kpackage { "smokeping":; }

	concat { "/etc/smokeping/config.d/Probes":; }

	concat::add_content { "0_Probes":
		content => "*** Probes ***",
		target  => "/etc/smokeping/config.d/Probes";
	}

	gen_smokeping::probe { "FPing":
		binary => "/usr/bin/fping";
	}

	setfacl { "Allow smokeping to read the rrd files":
		dir          => "/var/lib/smokeping",
		acl          => "user:smokeping:rw-",
		make_default => true;
	}
}

# Define: gen_smokeping::environment
#
# Actions:
#	Set up a smokeping environment, if the name is smokeping a normal install will be done
#
# Parameters:
#	owner
#		Same as smokeping
#	contact
#		Same as smokeping
#	cgiurl
#		Same as smokeping
#	mailhost
#		Same as smokeping
#	syslogfacility
#		Same as smokeping
#
# Depends:
#	gen_puppet
#
define gen_smokeping::environment(owner, contact, cgiurl, mailhost=false, syslogfacility=false) {
	$initname = $name ? {
		"smokeping" => "smokeping",
		default     => "smokeping_${name}",
	}

	if $lsbmajdistrelease < 6 {
		exec { "reload-${initname}":
			command     => "/etc/init.d/${initname} reload",
			refreshonly => true;
		}
	} else {
		exec { "reload-${initname}":
			command     => "/usr/sbin/service ${initname} reload",
			refreshonly => true;
		}
	}

	if $initname == "smokeping" {
		service { "${initname}":
			ensure     => "running",
			hasrestart => true,
			hasstatus  => true,
			enable     => true,
			subscribe  => [Kfile["/etc/smokeping/config.d/pathnames"],Concat["/etc/smokeping/config.d/Probes"],Gen_smokeping::Config["config"]];
		}

		concat { "/etc/smokeping/config.d/Targets":
			notify => Service[$initname];
		}

		concat::add_content { "0_Targets":
			content => "*** Targets ***\nmenu = Top\ntitle = Smokeping\nprobe = FPing",
			target  => "/etc/smokeping/config.d/Targets";
		}
		
		gen_smokeping::config {
			"General":
				content => template("gen_smokeping/general"),
				require => Package["smokeping"];
			"pathnames":
				content => template("gen_smokeping/pathnames"),
				require => Package["smokeping"];
		}
	} else {
		kfile {
			"/etc/smokeping/config.d/${name}":
				ensure => directory;
			"/etc/init.d/${initname}":
				mode    => 755,
				content => template("gen_smokeping/initscript"),
				notify  => Service[$initname];
			"/usr/share/smokeping/cgi-bin/smokeping_${name}.cgi":
				mode    => 755,
				content => template("gen_smokeping/smokeping.cgi"),
				require => Package["smokeping"];
		}

		gen_smokeping::config {
			"config_${name}":
				content  => template("gen_smokeping/config"),
				subdir   => $name,
				initname => $initname;
			"General_${name}":
				content  => template("gen_smokeping/general"),
				subdir   => $name,
				initname => $initname;
			"pathnames_${name}":
				content  => template("gen_smokeping/pathnames"),
				subdir   => $name,
				initname => $initname;
		}

		service { "${initname}":
			ensure     => "running",
			hasrestart => true,
			hasstatus  => true,
			enable     => true,
			require    => Kfile["/etc/init.d/${initname}"],
			subscribe  => [Concat["/etc/smokeping/config.d/Probes"],Gen_smokeping::Config["config_${name}","General_${name}","pathnames_${name}"]];
		}

		concat { "/etc/smokeping/config.d/${name}/Targets":
			require => Kfile["/etc/smokeping/config.d/${name}"],
			notify  => Service[$initname];
		}

		concat::add_content { "0_Targets_${name}":
			content => "*** Targets ***\nmenu = Top\ntitle = ${name} Smokeping\nprobe = FPing",
			target  => "/etc/smokeping/config.d/${name}/Targets";
		}
	}

#	gen_smokeping::targetgroup { "Local":
#	}

#	gen_smokeping::target { "LocalMachine":
#		host  => "localhost",
#		group => "Local",
#		probe => "FPing";
#	}
}

# Define: gen_smokeping::target
#
# Actions
#	Set up a target
#
# Parameters:
#	group
#		The group this target belongs in
#	probe
#		The probe to use
#	path
#		The path to let the probe check on
#	host
#		The host to probe
#	subdir
#		The config subdir where the Target file is located
#
# Depends:
#	gen_puppet
#
define gen_smokeping::target($group, $probe, $path=false, $host=false, $subdir=false) {
	$sanitized_name = regsubst($name, '[^a-zA-Z0-9\-_]', '_', 'G')
	$real_host      = $host ? {
		false   => $name,
		default => $host,
	}

	concat::add_content { "${group}_2_${name}":
		content    => template("gen_smokeping/target"),
		target     => $subdir ? {
			false   => "/etc/smokeping/config.d/Targets",
			default => "/etc/smokeping/config.d/${subdir}/Targets",
		},
		exported   => true,
		contenttag => ["smokeping"];
	}
}

# Define: gen_smokeping::targetgroup
#
# Actions
#	Set up a target group
#
# Parameters:
#	remark
#		Same as smokeping
#	subdir
#		The subdir in which the Targets file is located
#
# Depends:
#	gen_puppet
#
define gen_smokeping::targetgroup($remark=false, $subdir=false) {
	$sanitized_name = regsubst($name, '[^a-zA-Z0-9\-_]', '_', 'G')

	concat::add_content { "${name}_1":
		content    => template("gen_smokeping/targetgroup"),
		target     => $subdir ? {
			false   => "/etc/smokeping/config.d/Targets",
			default => "/etc/smokeping/config.d/${subdir}/Targets",
		},
		exported   => true,
		contenttag => ["smokeping"];
	}
}

# Define: gen_smokeping::probe
#
# Actions
#	Set up a probe
#
# Parameters:
#	package
#		The package needed for this probe
#	binary
#		Same as Echoping and probably other probes
#	forks
#		Same as Echoping and probably other probes
#	offset
#		Same as Echoping and probably other probes
#	step
#		Same as Echoping and probably other probes
#	accept_redirects
#		Same as Echoping and probably other probes
#	ignore_cache
#		Same as Echoping and probably other probes
#	ipversion
#		Same as Echoping and probably other probes
#	pings
#		Same as Echoping and probably other probes
#	port
#		Same as Echoping and probably other probes
#	priority
#		Same as Echoping and probably other probes
#	revalidate_data
#		Same as Echoping and probably other probes
#	timeout_value
#		Same as Echoping and probably other probes
#	tos
#		Same as Echoping and probably other probes
#	url
#		Same as Echoping and probably other probes
#	waittime
#		Same as Echoping and probably other probes
#
# Depends:
#	gen_puppet
#
define gen_smokeping::probe($package=false, $binary=false, $forks=false, $offset=false, $step=false, $accept_redirects=false,
		$ignore_cache=false, $ipversion=false, $pings=false, $port=false, $priority=false, $revalidate_data=false,
		$timeout_value=false, $tos=false, $url=false, $waittime=false) {
	if $package {
		class { "gen_base::${package}":; }
	}

	concat::add_content { "1_${name}":
		content    => template("gen_smokeping/probe"),
		target     => "/etc/smokeping/config.d/Probes",
		exported   => true,
		contenttag => "smokeping";
	}
}

# Define: gen_smokeping::config
#
# Actions:
#	Place a config file, only needed internally
#
# Parameters:
#	content
#		The content of the config file
#	subdir
#		The subdir where the config file should be located
#	initname
#		The name of the service to notify
#
# Depends:
#	gen_puppet
#
define gen_smokeping::config ($content, $subdir=false, $initname) {
	$filename = regsubst($name,'^(.*)_.*?$','\1')

	if $subdir {
		kfile { "/etc/smokeping/config.d/$subdir/${filename}":
			content => $content,
			notify  => Service[$initname];
		}
	} else {
		kfile { "/etc/smokeping/config.d/${filename}":
			content => $content,
			notify  => Service[$initname];
		}
	}
}
