class ferm {
	kpackage { "ferm":; }

	exec { "reload-ferm":
		command     => "/etc/init.d/ferm reload",
		subscribe   => File["/etc/ferm/ferm.conf"],
		refreshonly => true;
	}

	kfile { "/etc/ferm/ferm.conf":
		group   => "adm",
		require => Package["ferm"];
	}
}

class ferm::new {
	ipv4table { "filter":; }
	ipv6table { "filter":; }

#	kpackage { "ferm":; }

#	exec { "reload-ferm":
#		command     => "/etc/init.d/ferm reload",
#		subscribe   => File["/etc/ferm/ferm.conf"],
#		refreshonly => true;
#	}

	kfile {
		"/etc/ferm/ferm.d":
			ensure  => directory,
			group   => "adm",
			require => Package["ferm"];
		"/etc/ferm/ferm.conf_new":
			content => "@include 'ferm.d/';",
			group   => "adm",
			notify  => Exec["reload-ferm"];
	}

	define ipv4table() {
		fermfile {
			"${name}":
				content => "table ${name} {";
			"${name}_zzzz":
				content => "}";
		}
	}

	define ipv6table() {
		fermfile {
			"${name}":
				content => "domain ipv6 table ${name}";
			"${name}_zzzz":
				content => "}";
		}
	}

	define fermfile($content) {
		$new_content = "${content}\n"
		kfile { "/etc/ferm/ferm.d/${name}":
			content => $new_content;
		}
	}

}
