class arpwatch {
	kpackage { "arpwatch":; }

	service { "arpwatch":
		ensure    => running,
		require   => File["/etc/default/arpwatch"],
		subscribe => File["/etc/default/arpwatch"];
	}

	kfile { "/etc/default/arpwatch":
		require => Package["arpwatch"];
	}
}
