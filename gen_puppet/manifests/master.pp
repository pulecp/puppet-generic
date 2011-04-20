class gen_puppet::master ($servertype = 'passenger') {
	# Install the packages
	kpackage {
		"puppetmaster":
			ensure  => present,
			require => Kfile["/etc/default/puppetmaster"];
		"puppetmaster-common":
			ensure  => latest;
	}

	# Keep in mind this only counts for the default puppetmaster,
	# not for any additional puppetmasters!
	kfile { "/etc/default/puppetmaster":
		content => template('gen_puppet/default/puppetmaster'),
	}

	# These are needed for customer puppetmaster config when run
	# via passenger.
	kfile { ["/usr/local/share/puppet","/usr/local/share/puppet/rack"]:
		ensure  => directory;
	}
}

# gen_puppet::master::config
#
# Creates a custom puppetmaster. Use name 'default' if you want a
# single, default puppetmaster. (That way everything that usually
# says 'puppetmaster-myname' will just be 'puppetmaster'.) This
# type currently only supports passenger-based puppetmasters. It
# seems the way forward anyway.
#
# Keep in mind that since this is a generic class, we only provide
# the actual puppetmaster settings. We do not provide settings for
# the webserver, the database, puppet queue daemon or anything
# else.
#
define gen_puppet::master::config ($configfile = "/etc/puppet/puppet.conf", $debug = false,
				$factpath = '$vardir/lib/facter', $logdir = "/var/log/puppet", $pluginsync = true,
				$rackroot = "/usr/local/share/puppet/rack", $rundir = "/var/run/puppet",
				$ssldir = "/var/lib/puppet/ssl", $vardir = "/var/lib/puppet") {
	# If the name is 'default', we want to change the puppetmaster name (pname)
	# we're using for this instance to something without crud.
	if $name == 'default' {
		$pname = 'puppetmaster'
	} else {
		$sanitized_name = regsubst($name, '[^a-zA-Z0-9\-_]', '_', 'G')
		$pname - "puppetmaster-${sanitized_name}"
	}

	# This is the rack main directory for the app.
	$rackdir = "${rackroot}/${pname}"

	# Create the rack directories.
	kfile { ["${rackdir}","${rackdir}/public","${rackdir}/tmp"]:
		ensure => 'directory',
	}

	# Next come a whole lot of settings that are quite a bit different if we're
	# setting up a default puppetmaster, since that would share config with
	# the puppet client. We need to take that into account.
	if $name == 'default' {
		include gen_puppet::puppet_conf
	} else {
	}
}
