class radvd::server {
	kpackage { "radvd":; }

	service { "radvd":
		subscribe => File["/etc/radvd.conf"],
		require => File["/etc/radvd.conf"],
		ensure => running;
	}

	kfile { "/etc/radvd.conf":
		require => Package["radvd"];
	}
}
