# Author: Kumina bv <support@kumina.nl>

# Class: hylafax::server
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class hylafax::server {
	include gen_base::libfreetype6

	kpackage { "hylafax-server":
		ensure => latest,
	}

	service {
		"hylafax":
			require => Package["hylafax-server"],
			pattern => "hfaxd",
			ensure => running;
	}
}
