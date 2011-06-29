class gen_amavisd-new {
	kpackage { "amavisd-new":; }

	kservice { "amavis":
		require => Kpackage["amavisd-new"];
	}
}
