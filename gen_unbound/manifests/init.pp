#
# Class: gen_unbound
#
# Actions:
#  Install unbound, create a skeleton config, download the DNS root key and start unbound.
#
# Dependencies:
#  gen_puppet
#
class gen_unbound {
  kpackage { "unbound-anchor":; }
  kservice { "unbound":
    hasstatus => false,
    hasreload => false,
    require   => Exec["Install DNS root key for unbound"];
  }

  exec { "Install DNS root key for unbound":
    command     => "/usr/sbin/unbound-anchor",
    refreshonly => true,
    creates     => "/etc/unbound/root.key",
    require     => Kpackage["unbound-anchor"];
  }

  exec { "check-unbound.conf":
    command     => "/usr/sbin/unbound-checkconf",
    refreshonly => true,
    notify      => Exec["reload-unbound"];
  }

  concat { "/etc/unbound/unbound.conf":
    require => Package["unbound"],
    notify  => Exec["check-unbound.conf"];
  }

  concat::add_content {
    "00 unbound.conf header":
      content => template("gen_unbound/unbound.conf.header"),
      target  => "/etc/unbound/unbound.conf";
    "10 unbound.conf deny all by default":
      content => "\taccess-control: 0.0.0.0/0 refuse",
      target  => "/etc/unbound/unbound.conf";
  }

  gen_unbound::allow { ["127.0.0.1/24", "::1", "::ffff:127.0.0.1"]:;}
}

#
# Define: gen_unbound::allow
#
# Actions:
#  Add config for allowed subnets to unbound.conf
#
# Dependencies:
#  gen_unbound
#
define gen_unbound::allow {
  concat::add_content { "11 unbound.conf allow ${name}":
    target  => "/etc/unbound/unbound.conf",
    content => "\taccess-control: ${name} allow";
  }
}
