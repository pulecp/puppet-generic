class gen_nfs {
	kpackage { ["nfs-common","portmap"]:
		ensure => latest,
	}

	service { "portmap":
		ensure     => running,
		hasrestart => true,
		hasstatus  => false,
		pattern    => "/sbin/portmap",
		enable     => true,
		require    => Kpackage["nfs-common","portmap"],
	}

	service { "nfs-common":
		ensure     => running,
		hasrestart => true,
		hasstatus  => true,
		enable     => true,
		require    => Kpackage["nfs-common"],
	}
}
