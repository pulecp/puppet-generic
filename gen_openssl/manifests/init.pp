class gen_openssl::common {
	kpackage { "openssl":
		ensure => latest,
	}

	kfile {
		"/etc/ssl/certs":
			require  => Package["openssl"],
			checksum => "md5",
			recurse  => true;
	}
}

class gen_openssl::server {
	include gen_openssl::common

	notify { "This host includes a class that's illogical. You want to remove it.":; }
}

class gen_openssl::ca {
	include gen_openssl::common

	kfile {
		"/etc/ssl/newcerts":
			ensure  => directory,
			mode    => 750,
			require => Kpackage["openssl"];
		"/etc/ssl/requests":
			ensure  => directory,
			mode    => 750,
			require => Kpackage["openssl"];
		"/etc/ssl/Makefile":
			source  => "gen_openssl/Makefile",
			require => Kpackage["openssl"];
	}
}

define gen_openssl::create_ca ($length = 4096) {
	exec { "create ca secret key ${name}":
		command  => "/usr/bin/openssl genrsa -out '${name}' ${length}",
		creates  => "${name}",
		requires => Kpackage["openssl"],
	}
}

define gen_openssl::create_ca_csr () {
	# Bother, needs a config file for the values? Silly.
}
