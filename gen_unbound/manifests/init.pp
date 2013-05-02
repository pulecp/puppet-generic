#
# Class: gen_unbound
#
# Actions:
#  Install unbound, create a skeleton config, download the DNS root key and start unbound.
#
# Dependencies:
#  gen_puppet
#
class gen_unbound ($interfaces=['0.0.0.0','::0']) {
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

  if $stub_addr == 'localhost' or $stub_addr =~ /^127\./ {
    include gen_unbound::query_localhost
  }

  concat::add_content { "20 stubzone ${name}":
    target  => '/etc/unbound/unbound.conf',
    content => template('gen_unbound/unbound.conf.stubzone');
  }
}

#
# Class: gen_unbound::query_localhost
#
# Actions:
#  Configure Unbound to do queries to localhost
#
# Depends:
#  gen_unbound
#
class gen_unbound::query_localhost {
  concat::add_content { '09 Allow queries to localhost':
    target  => '/etc/unbound/unbound.conf',
    content => template('gen_unbound/unbound.conf.do-not-query-localhost');
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

#
# Define: gen_unbound::forward_zone
#
# Actions:
#  Configure a forward-zone
#
# Depends:
#  gen_unbound
#
define gen_unbound::forward_zone ($forward_host=false, $forward_addr=false, $forward_first=false) {
  if !($forward_host or $forward_addr) {
    fail("Please provide at least one \$forward_host or \$forward_addr")
  }

  concat::add_content { "30 forwardzone ${name}":
    target  => '/etc/unbound/unbound.conf',
    content => template('gen_unbound/unbound.conf.forwardzone');
  }
}

#
# Define: gen_unbound::reverse_1918_stub
#
# Action:
#  Create a stub-zone AND a local-zone for $name
#
# Parameters:
#  See gen_unbound::stub_zone
#
define gen_unbound::reverse_1918_stub ($stub_host=false, $stub_addr=false, $stub_prime=false, $stub_first=false) {
  gen_unbound::local_zone { $name:
    zonetype => 'transparent';
  }

  gen_unbound::stub_zone { $name:
    stub_host  => $stub_host,
    stub_addr  => $stub_addr,
    stub_prime => $stub_prime,
    stub_first => $stub_first;
  }
}

#
# Class: gen_unbound::all_1918_zones_local
#
# Actions:
#  Mark ALL RFC1918 zones as local-zones and mark them insecure
#  This is handy when you're forwarding all queries to another resolver that contains (parts) of these zones
#
# Depends:
#  gen_unbound
#
class gen_unbound::all_1918_zones_local {
  gen_unbound::local_zone { ['10.in-addr.arpa','16.172.in-addr.arpa', '17.172.in-addr.arpa', '18.172.in-addr.arpa',
                            '19.172.in-addr.arpa', '20.172.in-addr.arpa', '21.172.in-addr.arpa', '22.172.in-addr.arpa',
                            '23.172.in-addr.arpa', '24.172.in-addr.arpa', '25.172.in-addr.arpa', '26.172.in-addr.arpa',
                            '27.172.in-addr.arpa', '28.172.in-addr.arpa', '29.172.in-addr.arpa', '30.172.in-addr.arpa',
                            '31.172.in-addr.arpa', '168.192.in-addr.arpa']:
    zonetype => 'transparent';
  }

  gen_unbound::domain_insecure { ['10.in-addr.arpa','16.172.in-addr.arpa', '17.172.in-addr.arpa', '18.172.in-addr.arpa',
                                 '19.172.in-addr.arpa', '20.172.in-addr.arpa', '21.172.in-addr.arpa', '22.172.in-addr.arpa',
                                 '23.172.in-addr.arpa', '24.172.in-addr.arpa', '25.172.in-addr.arpa', '26.172.in-addr.arpa',
                                 '27.172.in-addr.arpa', '28.172.in-addr.arpa', '29.172.in-addr.arpa', '30.172.in-addr.arpa',
                                 '31.172.in-addr.arpa', '168.192.in-addr.arpa']:;
  }
}

#
# Define: gen_unbound::domain_insecure
#
# Action:
#  Set domain $name as always insecure (ignore all DNSSEC information of this domain)
#
# Depends:
#  gen_unbound
#
define gen_unbound::domain_insecure {
  concat::add_content { "18 domain-insecure ${name}":
    target  => '/etc/unbound/unbound.conf',
    content => "domain-insecure: ${name}\n";
  }
}
