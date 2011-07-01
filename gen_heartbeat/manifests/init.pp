# Author: Kumina bv <support@kumina.nl>

# Class: gen_heartbeat
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_heartbeat {
	kpackage { "heartbeat":
		ensure => latest,
	}

	service { "heartbeat":
		ensure     => running,
		hasrestart => true,
		hasstatus  => true,
		enable     => true,
		require    => [Kfile["/etc/ha.d/ha.cf","/etc/ha.d/authkeys"],
			Kpackage["heartbeat"]];
	}

	define ha_cf ($autojoin, $warntime, $deadtime,
		$initdead, $keepalive, $crm, $nodes) {
		if $nodes == false {
			fail("Nodes must be specified.")
		}

		kfile { "/etc/ha.d/ha.cf":
			content => template("gen_heartbeat/ha.cf.erb"),
			notify  => Service["heartbeat"],
			require => Kpackage["heartbeat"];
		}

		# We don't use auth-keys, as the port is firewalled and only open to the other hosts(s) in the cluster(done in kbp_heartbeat)
		kfile { "/etc/ha.d/authkeys":
			content => "auth 1\n1 crc",
			mode => 600,
			require => Kpackage["heartbeat"];
		}
	}
}
