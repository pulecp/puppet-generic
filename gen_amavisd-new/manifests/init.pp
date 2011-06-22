class gen_amavisd-new {
	kpackage { "amavisd-new":; }

	service { "amavis":
		enable     => true,
		ensure     => running,
		hasrestart => true,
		require    => Kpackage["amavisd-new"];
	}

	kfile { "/etc/amavis/conf.d/50-user":
		source => "gen_amavisd-new/conf.d/50-user",
		notify => Service["amavis"];
	}
}
