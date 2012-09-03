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
  package { ["unbound-anchor", "unbound"]:; }

  service { "unbound":
    hasstatus => false,
    require   => [Exec["Install DNS root key for unbound","check-unbound.conf"],Package["unbound"]];
  }

  exec {
    "Install DNS root key for unbound":
      command     => "/usr/sbin/unbound-anchor",
      creates     => "/etc/unbound/root.key",
      require     => [Package["unbound-anchor"],Exec['check-unbound.conf']];
    "check-unbound.conf":
      command     => "/usr/sbin/unbound-checkconf",
      refreshonly => true,
      notify      => Service["unbound"];
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

#
# Define: gen_unbound::stub_zone
#
# Actions:
#  Configure a stub-zone
#
# Depends:
#  kbp_unbound
#
define gen_unbound::stub_zone ($stub_host=false, $stub_addr=false, $stub_prime=false, $stub_first=false) {
    if !(($stub_host and ! $stub_addr) or (! $stub_host and $stub_addr)) {
      fail("Please supply either a \$stub_host or a \$stub_addr")
    }

    notify { [$stub_host]:; }

    concat::add_content { "20 stubzone ${name}":
      target  => '/etc/unbound/unbound.conf',
      content => template('gen_unbound/unbound.conf.stubzone');
    }
}
