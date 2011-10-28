# Author: Kumina bv <support@kumina.nl>

# Class: radvd::server
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class radvd::server {
	kpackage { "radvd":
		ensure => latest;
	}

	service { "radvd":
		subscribe => File["/etc/radvd.conf"],
		require => File["/etc/radvd.conf"],
		ensure => running;
	}

	kfile { "/etc/radvd.conf":
		require => Package["radvd"];
	}
}
