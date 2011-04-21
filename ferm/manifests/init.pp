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
	interface { ["lo_v46"]:
		action => "ACCEPT";
	}

	modstate {
		"INVALID_v46":;
		["ESTABLISHED_v46","RELATED_v46"]:
			action => "ACCEPT";
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
				content => template("ferm/rule");
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
				content => template("ferm/interface");
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
				content => template("ferm/modstate");
			}
		}
	}

	define policy($comment=false, $action=DROP, $table=filter, $chain=INPUT) {
		$real_name = regsubst($name,'^(.*)_(.*)$','\1')
		$ip_proto = regsubst($name,'^(.*)_(.*)$','\2')

		if $ip_proto == "v46" {
			policy { ["${real_name}_v4","${real_name}_v6"]:
				comment => $comment,
				action  => $action,
				table   => $table,
				chain   => $chain;
			}
		} else {
			fermfile { "${ip_proto}_${table}_${chain}_0000_${real_name}":
				content => template("ferm/policy");
			}
		}
	}

	define fermfile($content) {
		kfile { "/etc/ferm/ferm.d/${name}":
			content => $content;
		}
	}
}
