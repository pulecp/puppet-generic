class approx {
	kpackage { "approx":; }

	service  { "approx":
		ensure => running,
		require => Package["approx"],
		subscribe => File["/etc/approx/approx.conf"],
	}

	kfile { "/etc/approx/approx.conf":
		source => "approx/approx.conf",
		require => Package["approx"];
	}
}
