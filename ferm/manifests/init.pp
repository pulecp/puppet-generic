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
	table { 
		"filter":;
		"filter_v6":;
	}

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

	define table() {
		$real_name = regsubst($name,'^(.*)_(.*)$','\1')
		$ip_proto = regsubst($name,'^(.*)_(.*)$','\2')

		fermfile {
			"${name}":
				content => $ip_proto ? {
					"v6"    => "domain ipv6 table ${real_name} {",
					default => "table ${real_name} {",
				};
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
