# Author: Kumina bv <support@kumina.nl>

# Class: lvm
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class lvm {
	package { ["lvm2", "dmsetup"]:
		ensure => installed,
	}
}
