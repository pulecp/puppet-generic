class p910nd::server {
	kpackage { "p910nd":; }

	service {
		"p910nd":
			ensure => running,
			pattern => "p9100d",
			require => File["/etc/default/p910nd"],
			subscribe => File["/etc/default/p910nd"];
	}

	kfile {
		"/etc/default/p910nd":
			require => Package["p910nd"];
	}
}
