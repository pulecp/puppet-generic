# Author: Kumina bv <support@kumina.nl>

# Class: gen_puppet::queue
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_puppet::queue {
	include gen_base::libactiverecord_ruby18
	include gen_base::libstomp_ruby

	kpackage { "puppetmaster-common":
		ensure  => latest,
		require => Kpackage["libstomp-ruby","libactiverecord-ruby1.8"],
	}
}

# Define: gen_puppet::queue::runner
#
# Actions:
#	Setup a new init script per puppetmaster for which we
#	enable the queue. This is due to the default puppetqd
#	initscript not supporting multiple queues. Honestly,
#	multiple queues only make sense in a test puppetmaster
#	setup in which multiple puppetmasters are running.
#	Also makes sure that the initscripts are running.
#
# Parameters:
#	configfile
#		The configfile where it should look for the
#		database and stompserver configuration.
#		Defaults to /etc/puppet/puppet.conf.
#
# Depends:
#	gen_puppet
#	gen_puppet::queue
#
define gen_puppet::queue::runner ($configfile = false) {
	include gen_puppet::queue

	# If name is not default, make one up
	if $name != "default" {
		$cf = $configfile
		$scriptname = "puppetqd-${name}"
	} else {
		$cf = "/etc/puppet/puppet.conf"
		$scriptname = "puppetqd"
	}

	# The additional initscript
	kfile { "/etc/init.d/${scriptname}":
		content => template("gen_puppet/queue/initscript"),
		mode    => 755,
		require => Kpackage["puppetmaster-common"],
	}

	kfile { "/etc/default/${scriptname}":
		content => template("gen_puppet/queue/default"),
		require => Kpackage["puppetmaster-common"],
	}

	# The service
	service { $scriptname:
		hasstatus => true,
		ensure    => running,
		require   => [Kpackage["puppetmaster-common"],Kfile["/etc/init.d/${scriptname}","/etc/default/${scriptname}"]];
	}
}
