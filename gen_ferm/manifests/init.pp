# Author: Kumina bv <support@kumina.nl>

# Class: gen_ferm
#
# Actions:
#  Sets up the basics for a ferm firewall.
#
# Depends:
#  gen_puppet
#
class gen_ferm {
  # Needed for dns resolving
  include gen_base::libnet_dns_perl

  kservice { "ferm":
    hasstatus => false,
    ensure    => "undef",
    require   => Package["libnet-dns-perl"],
    pensure   => latest;
  }

  concat { "/etc/ferm/ferm.conf":
    group            => "adm",
    notify           => Exec["reload-ferm"],
    require          => Package["ferm"];
  }

  # Explicitly create these two rules; we want this for IPv6 even if there is no (public) IPv6 address
  # on any interface because 'localhost' also points to ::1 on newer (Debian wheezy) systems.
  # gen_ferm::rule won't create rules for IPv6 if IPv6 isn't configured and _v6 isn't specified.
  gen_ferm::rule { ['Accept local traffic_v4', 'Accept local traffic_v6']:
    interface => "lo",
    action    => "ACCEPT";
  }

  gen_ferm::mod {
    "INVALID":
      value  => "INVALID",
      action => "REJECT";
    "ESTABLISHED":
      value  => "(ESTABLISHED RELATED)",
      action => "ACCEPT";
  }

  # Needs to exist even if empty
  gen_ferm::chain { ['OUTPUT_filter_v4', 'OUTPUT_filter_v6']:; }

  @gen_ferm::table { ["filter_v4","filter_v6","mangle_v4","mangle_v6","nat_v4","nat_v6"]:; }

  Gen_ferm::Chain <| title == 'INPUT_filter_v4' |> {
    policy => 'DROP',
  }
  Gen_ferm::Chain <| title == 'FORWARD_filter_v4' |> {
    policy => 'DROP',
  }
  Gen_ferm::Chain <| title == 'OUTPUT_filter_v4' |> {
    policy => 'ACCEPT',
  }
  Gen_ferm::Chain <| title == 'INPUT_filter_v6' |> {
    policy => 'DROP',
  }
  Gen_ferm::Chain <| title == 'FORWARD_filter_v6' |> {
    policy => 'DROP',
  }
  Gen_ferm::Chain <| title == 'OUTPUT_filter_v6' |> {
    policy => 'ACCEPT',
  }
}

# Define: gen_ferm::rule
#
# Parameters:
#  name
#    Used as a comment for the rule, if ending on _v4 a v4 rule will be created, if ending on _v6 a v6 rule will be created, otherwise both v4 and v6 will be created
#  sport
#    The source port, defaults to false
#  chain
#    The chain the rule belongs in, defaults to INPUT
#  interface
#    The interface, defaults to false
#  dport
#    The destination port, defaults to false
#  ensure
#    Defines if the rule should be present, defaults to present
#  outerface
#    The outerface, defaults to false
#  saddr
#    The source address, defaults to false
#  daddr
#    The destination address, defaults to false
#  jump
#    The chain ferm should jump to, defaults to false
#  proto
#    The protocol, defaults to false
#  action
#    The action to take (for example ALLOW or DROP), defaults to DROP
#  icmptype
#    The icmptype, defaults to false
#  table
#    The table the rule should be in, defaults to filter
#  prio
#    The priority of the rule, this can be used to set ordering on rules, defaults to 500
#  exported
#    Defines whether the rule should be exported
#  ferm_tag
#    The tag to set on the exported file
#
# Actions:
#  Adds a rule.
#
# Depends:
#  gen_puppet
#
define gen_ferm::rule($prio=500, $interface=false, $outerface=false, $saddr=false, $daddr=false, $proto=false,
    $icmptype=false, $sport=false, $dport=false, $jump=false, $action=DROP, $table=filter,
    $chain=INPUT, $ensure=present, $exported=false, $ferm_tag=false, $fqdn = $::fqdn, $ipaddress6=false, $customtag="foobar") {
  if $customtag != "foobar" { notify { "gen_ferm::rule ${name} customtag ${customtag}":; } }
  $real_name = regsubst($name,'^(.*)_(v4?6?)$','\1')
  $sanitized_name = regsubst($real_name, '[^a-zA-Z0-9\-_]', '_', 'G')
  $ip_proto = regsubst($name,'^(.*)_(v4?6?)$','\2')
  $saddr_is_ip = $saddr ? {
    /(! )?\d+\.\d+\.\d+\.\d+\/?\d*/ => "ipv4",
    /(! )?.*:.*:.*\/?d*/            => "ipv6",
    default                         => false,
  }
  $daddr_is_ip = $daddr ? {
    /(! )?\d+\.\d+\.\d+\.\d+\/?\d*/ => "ipv4",
    /(! )?.*:.*:.*\/?d*/            => "ipv6",
    default                         => false,
  }

  if ($sport or $dport) and ! $proto {
    fail("sport or dport supplied without proto in gen_ferm::rule ${name}")
  }

  if $ip_proto == "v46" or $ip_proto == $name {
    if ! $::ipaddress6 and ! $ipaddress6 {
      rule { "${real_name}_v4":
        prio      => $prio,
        interface => $interface,
        outerface => $outerface,
        saddr     => $saddr,
        daddr     => $daddr,
        proto     => $proto,
        icmptype  => $icmptype,
        sport     => $sport,
        dport     => $dport,
        jump      => $jump,
        action    => $action,
        table     => $table,
        chain     => $chain,
        ensure    => $ensure,
        exported  => $exported,
        ferm_tag  => $ferm_tag;
      }
    } else {
      rule { ["${real_name}_v4","${real_name}_v6"]:
        prio      => $prio,
        interface => $interface,
        outerface => $outerface,
        saddr     => $saddr,
        daddr     => $daddr,
        proto     => $proto,
        icmptype  => $icmptype,
        sport     => $sport,
        dport     => $dport,
        jump      => $jump,
        action    => $action,
        table     => $table,
        chain     => $chain,
        ensure    => $ensure,
        exported  => $exported,
        ferm_tag  => $ferm_tag;
      }
    }
  } elsif ($ip_proto=="v4" and ! ($saddr_is_ip=="ipv6") and ! ($daddr_is_ip=="ipv6")) or ($ip_proto=="v6" and ! ($saddr_is_ip=="ipv4") and ! ($daddr_is_ip=="ipv4")) {
    realize Gen_ferm::Table["${table}_${ip_proto}"]
    if ! defined(Gen_ferm::Chain["${chain}_${table}_${ip_proto}"]) {
      gen_ferm::chain { "${chain}_${table}_${ip_proto}":; }
    }

    concat::add_content { "${ip_proto}_${table}_${chain}_${prio}_${sanitized_name}":
      target     => "/etc/ferm/ferm.conf",
      content    => $ip_proto ? {
        "v4" => template("gen_ferm/rule_v4"),
        "v6" => template("gen_ferm/rule_v6"),
      },
      ensure     => $ensure,
      exported   => $exported,
      contenttag => $ferm_tag,
      require    => Gen_ferm::Chain["${chain}_${table}_${ip_proto}"];
    }
  }
}

# Define: gen_ferm::mod
#
# Parameters:
#  table
#    The table the mod should be in, defaults to filter
#  chain
#    The chain the mod should be in, defaults to INPUT
#  mod
#    The mod type to use, defaults to state
#  param
#    The param to use, defaults to state
#  value
#    The value of the param, defaults to false
#  action
#    The action to take (for example ALLOW or DROP), defaults to DROP
#  comment
#    The comment to attack to the mod, defaults to false
#  name
#    Used as a comment for the mod, if ending on _v4 a v4 mod will be created, if ending on _v6 a v6 mod will be created, otherwise both v4 and v6 will be created
#
# Actions:
#  Adds a mod.
#
# Depends:
#  gen_puppet
#
define gen_ferm::mod($comment=false, $table=filter, $chain=INPUT, $mod=state, $param=state, $value=false, $action=DROP) {
  $real_name = regsubst($name,'^(.*)_(v4?6?)$','\1')
  $ip_proto  = regsubst($name,'^(.*)_(v4?6?)$','\2')

  if $ip_proto == "v46" or $ip_proto == $name {
    mod { ["${real_name}_v4","${real_name}_v6"]:
      comment => $comment,
      table   => $table,
      chain   => $chain,
      mod     => $mod,
      param   => $param,
      value   => $value,
      action  => $action;
    }
  } else {
    realize Gen_ferm::Table["${table}_${ip_proto}"]
    if ! defined(Gen_ferm::Chain["${chain}_${table}_${ip_proto}"]) {
      gen_ferm::chain { "${chain}_${table}_${ip_proto}":; }
    }

    concat::add_content { "${ip_proto}_${table}_${chain}_0001_${real_name}":
      target  => "/etc/ferm/ferm.conf",
      content => template("gen_ferm/mod"),
      require => Gen_ferm::Chain["${chain}_${table}_${ip_proto}"];
    }
  }
}

# Define: gen_ferm::chain
#
# Parameters:
#  table
#    The table the chain should be in, defaults to filter
#  policy
#    The default policy, defaults to false
#  name
#    Used as a comment for the chain, if ending on _v4 a v4 chain will be created, if ending on _v6 a v6 chain will be created, otherwise both v4 and v6 will be created
#
# Actions:
#  Add a ferm chain.
#
# Depends:
#  gen_puppet
#
define gen_ferm::chain($policy=false) {
  include gen_ferm

  $real_name = regsubst($name,'^(.*)_(.*)_(v4?6?)$','\1')
  $table     = regsubst($name,'^(.*)_(.*)_(v4?6?)$','\2')
  $ip_proto  = regsubst($name,'^(.*)_(.*)_(v4?6?)$','\3')

  realize Gen_ferm::Table["${table}_${ip_proto}"]

  concat::add_content {
    "${ip_proto}_${table}_${real_name}":
      target  => "/etc/ferm/ferm.conf",
      content => "\tchain ${real_name} {",
      require => Gen_ferm::Table["${table}_${ip_proto}"];
    "${ip_proto}_${table}_${real_name}_zzzz":
      target  => "/etc/ferm/ferm.conf",
      content => "\t}",
      require => Gen_ferm::Table["${table}_${ip_proto}"];
  }

  if $policy {
    concat::add_content { "${ip_proto}_${table}_${real_name}_0000":
      target  => "/etc/ferm/ferm.conf",
      content => "\t\tpolicy ${policy};",
      require => Gen_ferm::Table["${table}_${ip_proto}"];
    }
  }
}

# Define: gen_ferm::table
#
# Parameters
#  name
#    Used as a comment for the table, if ending on _v4 a v4 table will be created, if ending on _v6 a v6 table will be created, otherwise both v4 and v6 will be created
#
# Actions:
#  Creates a table entry.
#
# Depends:
#  gen_puppet
#
define gen_ferm::table() {
  $real_name = regsubst($name,'^(.*)_(v4?6?)$','\1')
  $ip_proto  = regsubst($name,'^(.*)_(v4?6?)$','\2')

  concat::add_content {
    "${ip_proto}_${real_name}":
      target  => "/etc/ferm/ferm.conf",
      content => $ip_proto ? {
        "v4" => "table ${real_name} {",
        "v6" => "domain ip6 table ${real_name} {",
      };
    "${ip_proto}_${real_name}_zzzz":
      target  => "/etc/ferm/ferm.conf",
      content => "}";
  }
}

# Define: gen_ferm::hook
#
# Parameters
#  name
#    Used as a comment for the hook
#
# Actions:
#  Creates a @hook entry.
#
# Depends:
#  gen_puppet
#
define gen_ferm::hook($type, $command) {
  validate_re($type, ['^pre$','^post$','^flush$'], 'Type needs to be one of pre, post or flush.')

  concat::add_content {
    "hook_${name}":
      target  => "/etc/ferm/ferm.conf",
      order   => 10,
      content => "@hook ${type} \"${command}\";";
  }
}
