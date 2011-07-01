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
	include gen_puppet::master

	# Install the stomp gem
	kpackage { "libstomp-ruby":
		ensure => latest,
	}

	# The service
	service { "puppetqd":
		hasstatus => true,
		ensure    => running,
		require   => Kpackage["puppetmaster"];
	}

	kfile { "/etc/default/puppetqd":
		source => "gen_puppet/default/puppetqd",
	}
}
