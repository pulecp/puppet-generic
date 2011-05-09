class gen_nfs::client {
	include gen_nfs
}

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
