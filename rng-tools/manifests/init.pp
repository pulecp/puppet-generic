# Author: Kumina bv <support@kumina.nl>

# Class: rng-tools
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class rng-tools {
	kpackage { "rng-tools":
		ensure => installed;
	}

	kfile { "/etc/default/rng-tools":
		source  => "rng-tools/default/rng-tools",
		notify  => Service["rng-tools"],
		require => Package["rng-tools"];
	}

	service { "rng-tools":
		ensure    => running,
		pattern   => "/usr/sbin/rngd",
		hasstatus => false,
		require   => File["/etc/default/rng-tools"];
	}
}
