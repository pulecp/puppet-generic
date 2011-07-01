# Author: Kumina bv <support@kumina.nl>

# Class: gen_base::wget
#
# Actions:
#	Set up wget
#
# Depends:
#	gen_puppet
#
class gen_base::wget {
	kpackage { "wget":
		ensure => latest;
	}
}
