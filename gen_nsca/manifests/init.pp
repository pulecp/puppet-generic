class gen_nsca::server {
	kpackage { "nsca":; }

	service { "nsca":
		enable     => true,
		ensure     => running,
		hasrestart => true,
		subscribe  => File["/etc/nsca.cfg"],
	}

	kfile { "/etc/nsca.cfg":
		source  => "gen_nsca/nsca.cfg",
		mode    => 640,
		group   => "nagios",
		require => Package["nsca"];
	}
}

class gen_nsca::client {
	kfile { "/etc/send_nsca.cfg":
		source  => "gen_nsca/nsca.cfg",
		mode    => 640;
	}
}
