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

	define table($ipv4=true) {
		$new_name = $ipv4 ? {
			true  => $name,
			false => "${name}_ipv6",
		}

		fermfile {
			"${name}":
				content => $ipv4 ? {
					true  => "table ${name} {",
					false => "domain ipv6 table ${name} {",
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
