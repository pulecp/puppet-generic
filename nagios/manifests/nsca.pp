class nagios::nsca {
	kpackage { "nsca":; }

	service { "nsca":
		enable => true,
		ensure => running,
		hasrestart => true,
		subscribe => File["/etc/nsca.cfg"],
	}

	kfile { "/etc/nsca.cfg":
		source => "nagios/nsca/nsca.cfg",
		mode => 640,
		group => "nagios",
		require => Package["nsca"];
	}
}
