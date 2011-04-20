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
	chain {
		"INPUT_v4":
			table => "filter",
			policy => "DROP";
		"INPUT_v6":
			table => "filter",
			policy => "DROP";
		"OUTPUT_v4":
			table => "filter",
			policy => "ACCEPT";
		"OUTPUT_v6":
			table => "filter",
			policy => "ACCEPT";
		"FORWARD_v4":
			table => "filter",
			policy => "DROP";
		"FORWARD_v6":
			table => "filter",
			policy => "DROP";
	}

	table {
		"filter_v4":;
		"filter_v6":;
	}
	@table {
		"mangle_v4":;
		"mangle_v6":;
		"nat_v4":;
		"nat_v6":;
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

	define rule($comment, $table=filter, $chain=input) {
		$real_name = regsubst($name,'^(.*)_(.*)$','\1')
		$ip_proto = regsubst($name,'^(.*)_(.*)$','\2')

		fermfile {
			"${ip_proto}_${table}_${real_name}":
				content => "\tchain ${real_name} {",
				require => Table["${table}_${ip_proto}"];
			"${ip_proto}_${table}_${real_name}_zzzz":
				content => "\t}",
				require => Table["${table}_${ip_proto}"];
		}
	}

	define chain($policy, $table=filter) {
		$real_name = regsubst($name,'^(.*)_(.*)$','\1')
		$ip_proto = regsubst($name,'^(.*)_(.*)$','\2')

		fermfile {
			"${ip_proto}_${table}_${real_name}":
				content => "\tchain ${real_name} {",
				require => Table["${table}_${ip_proto}"];
			"${ip_proto}_${table}_${real_name}_0000":
				content => "\t\tpolicy ${policy} {",
				require => Table["${table}_${ip_proto}"];
			"${ip_proto}_${table}_${real_name}_zzzz":
				content => "\t}",
				require => Table["${table}_${ip_proto}"];
		}
	}

	define table() {
		$real_name = regsubst($name,'^(.*)_(.*)$','\1')
		$ip_proto = regsubst($name,'^(.*)_(.*)$','\2')

		fermfile {
			"${ip_proto}_${real_name}":
				content => $ip_proto ? {
					"v4" => "table ${real_name} {",
					"v6" => "domain ipv6 table ${real_name} {",
				};
			"${ip_proto}_${real_name}_zzzz":
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
