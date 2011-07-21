# Author: Kumina bv <support@kumina.nl>

# Class: gen_nsca
#
# Actions:
#	Set up nsca
#
# Depends:
#	gen_puppet
#
class gen_nsca {
	kservice { "nsca":
		subscribe => File["/etc/nsca.cfg"];
	}
}

# Class: gen_nsca::server
#
# Actions:
#	Set up an nsca server
#
# Depends:
#	gen_puppet
#
class gen_nsca::server {
	include gen_nsca

	kfile { "/etc/nsca.cfg":
		source  => "gen_nsca/nsca.cfg",
		mode    => 640,
		group   => "nagios",
		require => Package["nsca"];
	}
}

# Class: gen_nsca::client
#
# Actions:
#	Configure the nsca client
#
# Depends:
#	gen_puppet
#
class gen_nsca::client {
	include gen_nsca

	kfile { "/etc/send_nsca.cfg":
		source => "gen_nsca/nsca.cfg",
		mode   => 640;
	}
}
