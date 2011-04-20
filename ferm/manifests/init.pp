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
	rule {
		"Respond to ICMP packets_v4":
			proto    => "icmp",
			icmptype => "echo-request",
			action   => "ACCEPT";
		"SSH_v4":
			proto  => "tcp",
			dport  => "22",
			action => "ACCEPT";
		"Drop UDP packets_v4":
			prio  => "a0",
			proto => "udp";
		"Nicely reject tcp packets_v4":
			prio       => "a1",
			proto      => "tcp",
			action     => "REJECT",
			rejectwith => "tcp-reset";
		"Reject everything else_v4":
			prio   => "a2",
			action => "REJECT";
		"Drop UDP packets (forward)_v4":
			prio  => "a0",
			proto => "udp",
			chain => "FORWARD";
		"Nicely reject tcp packets (forward)_v4":
			prio       => "a1",
			proto      => "tcp",
			action     => "REJECT",
			rejectwith => "tcp-reset",
			chain      => "FORWARD";
		"Reject everything else (forward)_v4":
			prio   => "a2",
			action => "REJECT",
			chain  => "FORWARD";
		"Respond to ICMP packets (NDP)_v6":
			proto    => "icmpv6",
			icmptype => "(neighbour-solicitation neighbour-advertisement)",
			action   => "ACCEPT";
		"Respond to ICMP packets (diagnostic)_v6":
			proto    => "icmpv6",
			icmptype => "echo-request",
			action   => "ACCEPT";
		"SSH_v6":
			proto  => "tcp",
			dport  => "22",
			action => "ACCEPT";
		"Drop UDP packets_v6":
			prio  => "a0",
			proto => "udp";
		"Nicely reject tcp packets_v6":
			prio       => "a1",
			proto      => "tcp",
			action     => "REJECT",
			rejectwith => "tcp-reset";
		"Reject everything else_v6":
			prio   => "a2",
			action => "REJECT";
		"Drop UDP packets_v6 (forward)":
			prio  => "a0",
			proto => "udp",
			chain => "FORWARD";
		"Nicely reject tcp packets_v6 (forward)":
			prio       => "a1",
			proto      => "tcp",
			action     => "REJECT",
			rejectwith => "tcp-reset",
			chain      => "FORWARD";
		"Reject everything else_v6 (forward)":
			prio   => "a2",
			action => "REJECT",
			chain  => "FORWARD";
	}

	interface { ["lo_v4","lo_v6"]:
		action => "ACCEPT";
	}

	modstate {
		["INVALID_v4","INVALID_v6"]:;
		["ESTABLISHED_v4","RELATED_v4","ESTABLISHED_v6","RELATED_v6"]:
			action => "ACCEPT";
	}

	chain {
		["INPUT_v4","INPUT_v6","FORWARD_v4","FORWARD_v6"]:;
		["OUTPUT_v4","OUTPUT_v6"]:
			policy => "ACCEPT";
	}

	table { ["filter_v4","filter_v6"]:; }

	@table { ["mangle_v4","mangle_v6","nat_v4","nat_v6"]:; }

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

	define rule($prio=500, $saddr=false, $daddr=false, $proto=false, $icmptype=false, $sport=false, $dport=false, $action=DROP, $table=filter, $chain=INPUT) {
		$real_name = regsubst($name,'^(.*)_(.*?)$','\1')
		$ip_proto = regsubst($name,'^(.*)_(.*?)$','\2')

		fermfile { "${ip_proto}_${table}_${chain}_${prio}_${real_name}":
			content => template("ferm/rule"),
			require => Chain["${chain}_${ip_proto}"];
		}
	}

	define interface($comment=false, $action=DROP, $table=filter, $chain=INPUT) {
		$real_name = regsubst($name,'^(.*)_(.*)$','\1')
		$ip_proto = regsubst($name,'^(.*)_(.*)$','\2')

		fermfile { "${ip_proto}_${table}_${chain}_0002_${real_name}":
			content => template("ferm/interface"),
			require => Chain["${chain}_${ip_proto}"];
		}
	}

	define modstate($comment=false, $action=DROP, $table=filter, $chain=INPUT) {
		$real_name = regsubst($name,'^(.*)_(.*)$','\1')
		$ip_proto = regsubst($name,'^(.*)_(.*)$','\2')

		fermfile { "${ip_proto}_${table}_${chain}_0001_${real_name}":
			content => template("ferm/modstate"),
			require => Chain["${chain}_${ip_proto}"];
		}
	}

	define chain($policy=DROP, $table=filter) {
		$real_name = regsubst($name,'^(.*)_(.*)$','\1')
		$ip_proto = regsubst($name,'^(.*)_(.*)$','\2')

		fermfile {
			"${ip_proto}_${table}_${real_name}":
				content => "\tchain ${real_name} {\n",
				require => Table["${table}_${ip_proto}"];
			"${ip_proto}_${table}_${real_name}_0000":
				content => "\t\tpolicy ${policy};\n",
				require => Table["${table}_${ip_proto}"];
			"${ip_proto}_${table}_${real_name}_zzzz":
				content => "\t}\n",
				require => Table["${table}_${ip_proto}"];
		}
	}

	define table() {
		$real_name = regsubst($name,'^(.*)_(.*)$','\1')
		$ip_proto = regsubst($name,'^(.*)_(.*)$','\2')

		fermfile {
			"${ip_proto}_${real_name}":
				content => $ip_proto ? {
					"v4" => "table ${real_name} {\n",
					"v6" => "domain ipv6 table ${real_name} {\n",
				};
			"${ip_proto}_${real_name}_zzzz":
				content => "}\n";
		}
	}

	define fermfile($content) {
		kfile { "/etc/ferm/ferm.d/${name}":
			content => $content;
		}
	}
}
