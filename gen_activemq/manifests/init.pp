class gen_activemq {
	kpackage { "activemq":; }

	kservice { "activemq":
		require => Package["activemq"];
	}
}
