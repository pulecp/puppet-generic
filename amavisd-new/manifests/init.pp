class amavisd-new {
	kpackage { "amavisd-new":
		ensure => installed,
	}

	service { "amavis":
		enable     => true,
		ensure     => running,
		hasrestart => true,
		require    => Kpackage["amavisd-new"],
	}

	kfile { "/etc/amavis/conf.d/50-user":
		source => "amavisd-new/conf.d/50-user",
		notify => Service["amavis"],
	}
}
