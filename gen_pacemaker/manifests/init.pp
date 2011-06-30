# Copyright (C) 2010 Kumina bv, Ed Schouten <ed@kumina.nl>
# This works is published under the Creative Commons Attribution-Share
# Alike 3.0 Unported license - http://creativecommons.org/licenses/by-sa/3.0/
# See LICENSE for the full legal text.

class gen_pacemaker {
	kpackage { "pacemaker":; }

	concat { "/etc/heartbeat/cib.cfg":
		notify => Exec["reload cib.cfg"];
	}

	# This actually updates the configuration. But we only need to do this if
	# the file changes.
	exec { "reload cib.cfg":
		command     => "/usr/sbin/crm configure load update /etc/heartbeat/cib.cfg",
		refreshonly => true,
		require     => [File["/etc/heartbeat/cib.cfg"],Kpackage["pacemaker"],Service["heartbeat"]];
	}

	define cib_cfg ($content,$order) {
		concat::add_content { "${name}":
			target  => "/etc/heartbeat/cib.cfg",
			order   => $order,
			notify  => Exec["reload cib.cfg"],
			content => $content;
		}
	}

	define primitive ($provider, $location, $location_score,
		$location_name,
		$start_interval, $start_timeout,
		$monitor_interval, $monitor_timeout,
		$stop_interval, $stop_timeout,
		$params) {
		cib_cfg { "primitive_${name}":
			order   => 10,
			content => template("gen_pacemaker/primitive.erb"),
		}

		if $location {
			$loc_name = $location_name ? {
				false   => "prefer-${name}",
				default => $location_name,
			}
			gen_pacemaker::location { "${loc_name}":
				primitive => "${name}",
				score     => $location_score,
				resnode   => $location;
			}
		}
	}

	define master_slave ($primitive, $meta) {
		cib_cfg { "ms_${name}":
			order   => 20,
			content => template("gen_pacemaker/ms.erb");
		}
	}

	define location ($primitive, $score, $resnode) {
		cib_cfg { "location_${name}":
			order   => 30,
			content => template("gen_pacemaker/location.erb"),
		}
	}

	define colocation ($resource_1, $resource_2, $score) {
		cib_cfg { "colocation_${name}":
			order   => 40,
			content => template("gen_pacemaker/colocation.erb");
		}
	}

	define order ($score, $resource_1, $resource_2) {
		cib_cfg { "order_${name}":
			order   => 50,
			content => template("gen_pacemaker/order.erb");
		}
	}

	define group ($resources) {
		cib_cfg { "group_${name}":
			order   => 55,
			content => template("gen_pacemaker/group.erb");
		}
	}

	cib_cfg { "properties_${name}":
		order   => 60,
		content => "property \$id=\"cib-bootstrap-options\" \\
			cluster-infrastructure=\"Heartbeat\" \\
			stonith-enabled=\"false\" \\
			expected-quorum-votes=\"2\" \\
			no-quorum-policy=\"ignore\"";
	}
}
