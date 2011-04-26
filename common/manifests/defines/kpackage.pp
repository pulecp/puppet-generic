define kpackage ($ensure="present", $responsefile=false) {
	package { "${name}":
		ensure       => $ensure,
		responsefile => $responsefile ? {
			false   => undef,
			default => $responsefile,
		},
		require      => Exec["/usr/bin/apt-get update"];
	}
}
