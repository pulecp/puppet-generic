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
    hasstatus => $lstdistcodename ? {
      'squeeze' => false,
      default   => true,
    },
    require   => [Exec["check-unbound.conf"],Package["unbound"]];
  }

  exec {
    "Install DNS root key for unbound":
      command     => "/usr/sbin/unbound-anchor",
      creates     => "/var/lib/unbound/root.key",
      user        => 'unbound',
      returns     => [0,1],
      require     => [Concat['/etc/unbound/unbound.conf'],Package["unbound-anchor"]];
    "check-unbound.conf":
      command     => "/usr/sbin/unbound-checkconf",
      refreshonly => true,
      notify      => Service["unbound"],
      require     => Exec['Install DNS root key for unbound'];
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
#  gen_unbound
#
define gen_unbound::stub_zone ($stub_host=false, $stub_addr=false, $stub_prime=false, $stub_first=false) {
  if !($stub_host or $stub_addr) {
    fail("Please provide at least one \$stub_host or \$stub_addr")
  }

  concat::add_content { "20 stubzone ${name}":
    target  => '/etc/unbound/unbound.conf',
    content => template('gen_unbound/unbound.conf.stubzone');
  }
}

#
# Define: gen_unbound::local_zone
#
# Actions:
#  Configure a local-zone
#
# Depends:
#  gen_unbound
#
# ToDo:
#  Create a define for local-data, so puppet can add this data to the config file
#
define gen_unbound::local_zone ($zonetype) {
  if $zonetype in ['deny','refuse','static','transparent','typetransparent','redirect','nodefault'] {
    concat::add_content { "19 localzone ${name}":
      target  => '/etc/unbound/unbound.conf',
      content => "local-zone: ${name} ${zonetype}\n";
    }
  } else {
    fail("\$zonetype ${zonetype} is not valid (read the unbound documentation).")
  }
}
