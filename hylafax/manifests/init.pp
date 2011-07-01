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
	package {
		"hylafax-server":
			ensure => present;
	}

	service {
		"hylafax":
			require => Package["hylafax-server"],
			pattern => "hfaxd",
			ensure => running;
	}
}
