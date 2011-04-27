class ferm {
	kpackage { "ferm":
		ensure => latest;
	}

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
	include gen_puppet::concat

	interface { ["lo_v46"]:
		action => "ACCEPT";
	}

	modstate {
		"INVALID_v46":;
		["ESTABLISHED_v46","RELATED_v46"]:
			action => "ACCEPT";
	}

	chain {
		["INPUT_v46","FORWARD_v46"]:;
		"OUTPUT_v46":
			policy => "ACCEPT";
	}

	table { ["filter_v46"]:; }

	@table { ["mangle_v4","mangle_v6","nat_v4","nat_v6"]:; }

#	kpackage { "ferm":; }
	kpackage { "libnet-dns-perl":; }

#	exec { "reload-ferm":
#		command     => "/etc/init.d/ferm reload",
#		subscribe   => File["/etc/ferm/ferm.conf"],
#		refreshonly => true;
#	}

	concat { "/etc/ferm/ferm.conf_new":
		owner            => "root",
		group            => "adm",
		mode             => "644",
		remove_fragments => false;
	}

	define rule($prio=500, $saddr=false, $daddr=false, $proto=false, $icmptype=false, $sport=false, $dport=false, $action=DROP, $rejectwith=false, $table=filter, $chain=INPUT) {
		$real_name = regsubst($name,'^(.*)_(.*?)$','\1')
		$sanitized_name = regsubst($real_name, '[^a-zA-Z0-9\-_]', '_', 'G')
		$ip_proto = regsubst($name,'^(.*)_(.*?)$','\2')

		if $ip_proto == "v46" {
			rule { ["${real_name}_v4","${real_name}_v6"]:
				prio       => $prio,
				saddr      => $saddr,
				daddr      => $daddr,
				proto      => $proto,
				icmptype   => $icmptype,
				sport      => $sport,
				dport      => $dport,
				action     => $action,
				rejectwith => $rejectwith,
				table      => $table,
				chain      => $chain;
			}
		} else {
			fermfile { "${ip_proto}_${table}_${chain}_${prio}_${sanitized_name}":
				content => $ip_proto ? {
					"v4" => template("ferm/rule_v4"),
					"v6" => template("ferm/rule_v6"),
				},
				require => [Chain["${chain}_${ip_proto}"],Exec["reload-ferm"]];
			}
		}
	}

	define interface($comment=false, $action=DROP, $table=filter, $chain=INPUT) {
		$real_name = regsubst($name,'^(.*)_(.*)$','\1')
		$sanitized_name = regsubst($real_name, '[^a-zA-Z0-9\-_]', '_', 'G')
		$ip_proto = regsubst($name,'^(.*)_(.*)$','\2')

		if $ip_proto == "v46" {
			interface { ["${real_name}_v4","${real_name}_v6"]:
				comment => $comment,
				action  => $action,
				table   => $table,
				chain   => $chain;
			}
		} else {
			fermfile { "${ip_proto}_${table}_${chain}_0002_${real_name}":
				content => template("ferm/interface"),
				require => [Chain["${chain}_${ip_proto}"],Exec["reload-ferm"]];
			}
		}
	}

	define modstate($comment=false, $action=DROP, $table=filter, $chain=INPUT) {
		$real_name = regsubst($name,'^(.*)_(.*)$','\1')
		$ip_proto = regsubst($name,'^(.*)_(.*)$','\2')

		if $ip_proto == "v46" {
			modstate { ["${real_name}_v4","${real_name}_v6"]:
				comment => $comment,
				action  => $action,
				table   => $table,
				chain   => $chain;
			}
		} else {
			fermfile { "${ip_proto}_${table}_${chain}_0001_${real_name}":
				content => template("ferm/modstate"),
				require => [Chain["${chain}_${ip_proto}"],Exec["reload-ferm"]];
			}
		}
	}

	define chain($policy=DROP, $table=filter) {
		$real_name = regsubst($name,'^(.*)_(.*)$','\1')
		$ip_proto = regsubst($name,'^(.*)_(.*)$','\2')

		if $ip_proto == "v46" {
			chain { ["${real_name}_v4","${real_name}_v6"]:
				policy => $policy,
				table  => $table;
			}
		} else {
			fermfile {
				"${ip_proto}_${table}_${real_name}":
					content => "\tchain ${real_name} {",
					require => Table["${table}_${ip_proto}"];
				"${ip_proto}_${table}_${real_name}_0000":
					content => "\t\tpolicy ${policy};",
					require => Table["${table}_${ip_proto}"];
				"${ip_proto}_${table}_${real_name}_zzzz":
					content => "\t}",
					require => Table["${table}_${ip_proto}"];
			}
		}
	}

	define table() {
		$real_name = regsubst($name,'^(.*)_(.*)$','\1')
		$ip_proto = regsubst($name,'^(.*)_(.*)$','\2')

		if $ip_proto == "v46" {
			table { ["${real_name}_v4","${real_name}_v6"]:; }
		} else {
			fermfile {
				"${ip_proto}_${real_name}":
					content => $ip_proto ? {
						"v4" => "table ${real_name} {",
						"v6" => "domain ip6 table ${real_name} {",
					};
				"${ip_proto}_${real_name}_zzzz":
					content => "}";
			}
		}
	}

	define fermfile($content) {
		kbp_concat::add_content { $name:
			content => $content,
			target  => "/etc/ferm/ferm.conf_new";
		}
	}
}
