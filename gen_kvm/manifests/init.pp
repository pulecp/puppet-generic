# Author: Kumina bv <support@kumina.nl>

# Class: gen_kvm
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_kvm {
	# Not entirely sure what we want to do here yet. But I am sure we don't
	# want to do anything on lenny just yet.
	if $lsbmajdistrelease > 5 {
		# Ensure we have the kvm setup
		kpackage { "qemu-kvm":; }

		# If things seem broke for whatever reason, install hal
		#kpackage { "hal":; }
	}
}
