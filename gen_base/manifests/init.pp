# Author: Kumina bv <support@kumina.nl>

# Class: gen_base
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_base {
	kpackage { "wget":
		ensure => latest;
	}
}
