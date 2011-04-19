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
#	ipv6table { "filter":; }

	$tables = { "ipv4" => {
			"filter" => "1",
		}, "ipv6" => {
			"filter" => "2",
		}}

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
		notify { "${tables}['ipv4'][${name}]9999":; }
		fermfile {
			"${tables}['ipv4'][${name}]":
				content => "table ${name} {";
#			"${tables}['ipv4'][${name}]9999":
#				content => "}";
		}
	}

#	define ipv6table() {
#		fermfile {
#			"${tables}['ipv6'][${name}]":
#				content => "domain ipv6 table ${name}";
#			"${tables}['ipv6'][${name}]9999":
#				content => "}";
#		}
#	}

	define fermfile($content) {
		kfile { "/etc/ferm/ferm.d/${name}":
			content => $content,
		}
	}

}
