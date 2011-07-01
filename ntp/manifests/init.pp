# Author: Kumina bv <support@kumina.nl>

# Class: ntp
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class ntp {
	kpackage { "ntp":
		ensure => latest;
	}

	service { "ntp":
		hasrestart => true,
		hasstatus  => true,
		ensure 	   => running,
		require    => Package["ntp"];
	}
}

