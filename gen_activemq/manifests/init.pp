# Author: Kumina bv <support@kumina.nl>

# Class: gen_activemq
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_activemq {
	kpackage { "activemq":; }

	kservice { "activemq":
		require => Package["activemq"];
	}
}
