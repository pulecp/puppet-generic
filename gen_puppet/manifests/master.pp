class gen_puppet::master {
	# Install the packages
	kpackage {
		"puppetmaster":
			ensure  => present,
			require => Kfile["/etc/default/puppetmaster"];
		"puppetmaster-common":
			ensure  => latest;
	}

	kfile { "/etc/default/puppetmaster":
		source => "gen_puppet/default/puppetmaster",
	}
}
