# Author: Kumina bv <support@kumina.nl>

# Class: gen_nfs::client
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_nfs::client {
	include gen_nfs
}

# Define: gen_nfs::client::mount
#
# Parameters:
#	source
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define gen_nfs::client::mount($source) {
	mount { $name:
		ensure  => "mounted",
		device  => $source,
		fstype  => "nfs",
		options => "proto=udp,wsize=1024,rsize=1024",
		dump    => 0,
		pass    => 0,
		require => [Kpackage["nfs-common"], Kfile[$name]],
	}

	kfile { $name:
		ensure => directory,
	}
}
