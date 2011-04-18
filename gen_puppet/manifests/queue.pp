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
}
