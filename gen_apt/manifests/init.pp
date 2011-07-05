# Author: Kumina bv <support@kumina.nl>

# Class: gen_apt
#
# Actions:
#	Set up apt preferences using concat when on Lenny or older and a .d dir otherwise. Set up apt sources using a .d dir.
#
# Depends:
#	gen_puppet
#
class gen_apt {
	if $lsbmajdistrelease < 6 {
		$preferences_file = "/etc/apt/preferences"

		concat { $preferences_file:
			mode => 440;
		}
	} else {
		kfile { "/etc/apt/preferences":
			ensure => absent;
		}
	}

	kfile {
		# Putting files in a directory is much easier to manage with
		# Puppet than modifying /etc/apt/sources.lists.
		"/etc/apt/sources.list":
			ensure => absent,
			notify => Exec["/usr/bin/apt-get update"];
		"/etc/apt/sources.list.d":
			ensure => directory,
			notify => Exec["/usr/bin/apt-get update"];
		"/etc/apt/keys":
			ensure => directory;
		# Increase the available cachesize
		"/etc/apt/apt.conf.d/50cachesize":
			content => "APT::Cache-Limit \"33554432\";\n",
			notify  => Exec["/usr/bin/apt-get update"];
	}

	# Run apt-get update when anything beneath /etc/apt/sources.list.d changes
	exec { "/usr/bin/apt-get update":
		refreshonly => true;
	}
}

# Define: gen_apt::preference
#
# Parameters:
#	repo
#		The repo to pin on, defaults to ${lsbdistcodename}-backports
#	version
#		The version to pin on, defaults to false
#	prio
#		The prio to give to the pin, defaults to 999
#	package
#		The package to pin, defaults to ${name}
#
# Actions:
#	Pins a package to a specific version or repo
#
# Depends:
#	gen_puppet
#
define gen_apt::preference($package=false, $repo=false, $version=false, $prio="999") {
	$use_repo = $repo ? {
		false   => "${lsbdistcodename}-backports",
		default => $repo,
	}

	if $lsbmajdistrelease < 6 {
		concat::add_content { "${name}":
			content => template("gen_apt/preference"),
			target  => "/etc/apt/preferences",
			notify  => Exec["/usr/bin/apt-get update"];
		}
	} else {
		kfile { "/etc/apt/preferences.d/${name}":
			content => template("gen_apt/preference"),
			notify  => Exec["/usr/bin/apt-get update"];
		}
	}
}

# Define: gen_apt::source
#
# Parameters:
#	name
#		THe package to define the source of
#	sourcetype
#		The type of the source, defaults to deb
#	distribution
#		The distribution of the source, defaults to stable
#	components
#		An array of components, for example main, nonfree, contrib, defaults to []
#	ensure
#		Defines if the source should be present, options are present and false, defaults to present
#	comment
#		Adds a comment to the source, defaults to false
#	uri
#		The uri of the source
#
# Actions:
#	Pins a package to a source.
#
# Depends:
#	gen_puppet
#
define gen_apt::source($uri, $sourcetype="deb", $distribution="stable", $components=[], $ensure="present", $comment=false) {
	kfile { "/etc/apt/sources.list.d/${name}.list":
		ensure  => $ensure,
		content => template("gen_apt/source.list"),
		require => File["/etc/apt/sources.list.d"],
		notify  => Exec["/usr/bin/apt-get update"];
	}
}

# Define: gen_apt::key
#
# Actions:
#	Import a repo key.
#
# Parameters:
#	name
#		The key to import.
#
# Depends:
#	gen_puppet
#
define gen_apt::key {
	exec { "/usr/bin/apt-key add /etc/apt/keys/${name}":
		unless  => "/usr/bin/apt-key list | grep -q ${name}",
		require => File["/etc/apt/keys/${name}"],
		notify  => Exec["/usr/bin/apt-get update"];
	}

	kfile { "/etc/apt/keys/${name}":
		source => "kbp_apt/keys/${name}";
	}
}

# Class: gen_apt::cron_apt
#
# Actions:
#	Install cron-apt
#
# Depends:
#	gen_puppet
#
class gen_apt::cron_apt {
	kpackage { "cron-apt":
		ensure => latest;
	}

	concat {"/etc/cron.d/cron-apt":;}
}

# Define: gen_apt::cron_apt::config
#
# Actions:
#	Create configuration for cron-apt
#
# Parameters:
#	configfile
#		The path to the config file for cron_apt
#	mailto
#		Where the cron-apt email should go to; see /usr/share/doc/cron-apt/examples/config
#	mailon
#		The condition cron-apt should mail on; see /usr/share/doc/cron-apt/examples/config
#	apt_options
#		Additional parameters to pass to apt-get; see /usr/share/doc/cron-apt/examples/config
#	apt_hostname
#		The hostname to put in the subject of the email; see /usr/share/doc/cron-apt/examples/config
#	crontime
#		The time to start the apt-get update (in cron format, like 0 4 * * * for 4 o'clock every night)
#
# Depends:
#	gen_puppet
#	gen_apt::cron_apt
#
define gen_apt::cron_apt::config ($mailto, $mailon, $apt_options="", $apt_hostname=false, $configfile="/etc/cron-apt/config", $crontime="0 3 * * *") {
	include gen_apt::cron_apt
	$config_hostname = $apt_hostname ? {
		false   => "${fqdn}",
		default => $apt_hostname,
	}

	kfile { "${configfile}":
		content => template("gen_apt/cron_apt_configfile"),
		require => Kpackage["cron-apt"];
	}

	$safe_configfile = regsubst($configfile, '/', '_')

	concat::add_content { "${safe_configfile}":
		target  => "/etc/cron.d/cron-apt",
		content => template("gen_apt/cron_apt_cron"),
		require => Kfile["${configfile}"];
	}
}
