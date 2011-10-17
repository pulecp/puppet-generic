# Author: Kumina bv <support@kumina.nl>

# Class: gen_heartbeat
#
# Actions:
#	Installs heartbeat and imports all configuration fragments.
#
# Depends:
#	gen_puppet
#
class gen_heartbeat ($customtag="heartbeat_${environment}") {
	kservice { "heartbeat":; }

	# These ekfiles contain the configuration fragments for heartbeat.
	Ekfile <<| tag == $customtag |>>
	concat { "/etc/heartbeat/ha.cf":
		notify           => Service["heartbeat"];
	}

	# We don't use auth-keys, as the port is firewalled and only open to the other hosts(s) in the cluster(done in kbp_heartbeat)
	kfile { "/etc/ha.d/authkeys":
		content => "auth 1\n1 crc",
		mode => 600,
	}
}

# Define: gen_heartbeat::ha_cf
#
# Actions:
#	Insert some fragments for the ha.cf file for heartbeat
#
#	Parameters
#		autojoin
#			see man 5 ha.cf
#		warntime
#			see man 5 ha.cf
#		deadtime
#			see man 5 ha.cf
#		initdead
#			see man 5 ha.cf
#		keepalive
#			see man 5 ha.cf
#		crm
#			see man 5 ha.cf
#		node_name
#			The name of the node(this is used to build the node directives in ha.cf)
#		node_dev
#			The device used for heartbeat communication
#		node_ip
#			The IP used 
#		customtag
#			Used when exporting and importing the configuration options. Change this when you have more than 1 heartbeat cluster.
#
# Depends:
#	gen_puppet
#
define gen_heartbeat::ha_cf ($autojoin="none", $warntime=5, $deadtime=15, $initdead=60, $keepalive=2, $crm="respawn", $node_name=$hostname, $node_dev="eth0", $node_ip=$ipaddress_eth0, $customtag="heartbeat_${environment}") {
	concat::add_content {
		"default heartbeat config":
			content    => template("gen_heartbeat/ha.cf.erb"),
			exported   => true,
			target     => "/etc/heartbeat/ha.cf",
			contenttag => $customtag;
		"heartbeat node ${node_name}":
			content => "node ${node_name}\nucast ${node_dev} ${node_ip}",
			exported => true,
			target     => "/etc/heartbeat/ha.cf",
			contenttag => $customtag;
	}
}
