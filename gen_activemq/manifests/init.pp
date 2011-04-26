class gen_activemq {
	kpackage { "activemq":; }

	service { "activemq":
		ensure     => running,
		hasrestart => true,
		require    => Package["activemq"];
	}

	exec { "reload-activemq":
		command     => "/etc/init.d/activemq reload",
		refreshonly => true;
	}
}
