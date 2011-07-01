# Author: Kumina bv <support@kumina.nl>

# Class: gen_xvfb
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_xvfb {
	kpackage { "xvfb":
		ensure => installed;
	}
}

