class gen_puppet::master {
	# Install the packages
	kpackage {
		"puppetmaster":
			ensure  => present,
			require => Kfile["/etc/default/puppetmaster","/etc/apt/preferences.d/puppetmaster"];
		"puppetmaster-common":
			ensure  => latest;
	}
}
