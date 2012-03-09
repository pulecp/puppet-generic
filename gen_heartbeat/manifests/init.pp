# Author: Kumina bv <support@kumina.nl>

# Class: gen_heartbeat
#
# Actions:
#  Installs heartbeat and imports all configuration fragments.
#
# Depends:
#  gen_puppet
#
class gen_heartbeat ($autojoin="none", $warntime=5, $deadtime=15, $initdead=60, $keepalive=2, $crm="respawn",
      $node_name=$hostname, $node_dev="eth0", $node_ip=$ipaddress_eth0, $heartbeat_tag="heartbeat_${environment}") {
  include gen_base::libxml2
  include gen_base::libxml2_utils
  kservice { "heartbeat":; }

  concat { "/etc/heartbeat/ha.cf":
    require => Package["heartbeat"],
    notify  => Service["heartbeat"];
  }

  concat::add_content { "default heartbeat config":
    content => template("gen_heartbeat/ha.cf.erb"),
    target  => "/etc/heartbeat/ha.cf";
  }

  @@concat::add_content { "heartbeat node ${node_name}":
    content => "node ${node_name}\nucast ${node_dev} ${node_ip}",
    target  => "/etc/heartbeat/ha.cf",
    tag     => $heartbeat_tag;
  }

  Concat::Add_content <<| tag == $heartbeat_tag |>>

  # We don't use auth-keys, as the port is firewalled and only open to the other hosts(s) in the cluster(done in kbp_heartbeat)
  file { "/etc/ha.d/authkeys":
    content => "auth 1\n1 crc",
    mode    => 600,
    require => Package["heartbeat"];
  }
}
