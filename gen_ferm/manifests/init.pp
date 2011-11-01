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
    ensure    => false,
    require   => Kpackage["libnet-dns-perl"],
    pensure   => latest;
  }

  concat { "/etc/ferm/ferm.conf":
    group            => "adm",
    notify           => Exec["reload-ferm"],
    require          => Kpackage["ferm"];
  }

  rule { "Accept local traffic":
    interface => "lo",
    action    => "ACCEPT";
  }

  mod {
    "INVALID":
      value => "INVALID";
    "ESTABLISHED":
      value  => "(ESTABLISHED RELATED)",
      action => "ACCEPT";
  }

  @chain {
    ["INPUT_v4","INPUT_v6","FORWARD_v4","FORWARD_v6"]:
      policy => "DROP";
    ["OUTPUT_v4","OUTPUT_v6"]:
      policy => "ACCEPT";
  }

  # Needs to exist even if empty
  realize Chain["OUTPUT_v4","OUTPUT_v6"]

  @table { ["filter_v4","filter_v6","mangle_v4","mangle_v6","nat_v4","nat_v6"]:; }
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
#  customtag
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
    $chain=INPUT, $ensure=present, $exported=false, $customtag=false) {
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

  if $ip_proto == "v46" or $ip_proto == $name {
    if ($saddr == $fqdn or $daddr == $fqdn) and ! $ipaddress6 {
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
        customtag => $customtag;
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
        customtag => $customtag;
      }
    }
  } elsif ($ip_proto=="v4" and ! ($saddr_is_ip=="ipv6") and ! ($daddr_is_ip=="ipv6")) or ($ip_proto=="v6" and ! ($saddr_is_ip=="ipv4") and ! ($daddr_is_ip=="ipv4")) {
    realize Table["${table}_${ip_proto}"]
    realize Chain["${chain}_${ip_proto}"]

    fermfile { "${ip_proto}_${table}_${chain}_${prio}_${sanitized_name}":
      content   => $ip_proto ? {
        "v4" => template("gen_ferm/rule_v4"),
        "v6" => template("gen_ferm/rule_v6"),
      },
      ensure    => $ensure,
      exported  => $exported,
      customtag => $customtag,
      require   => Chain["${chain}_${ip_proto}"];
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
    realize Table["${table}_${ip_proto}"]
    realize Chain["${chain}_${ip_proto}"]

    fermfile { "${ip_proto}_${table}_${chain}_0001_${real_name}":
      content => template("gen_ferm/mod"),
      require => Chain["${chain}_${ip_proto}"];
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
define gen_ferm::chain($policy=false, $table=filter) {
  include gen_ferm

  $real_name = regsubst($name,'^(.*)_(v4?6?)$','\1')
  $ip_proto  = regsubst($name,'^(.*)_(v4?6?)$','\2')

  fermfile {
    "${ip_proto}_${table}_${real_name}":
      content => "\tchain ${real_name} {",
      require => Table["${table}_${ip_proto}"];
    "${ip_proto}_${table}_${real_name}_zzzz":
      content => "\t}",
      require => Table["${table}_${ip_proto}"];
  }

  if $policy {
    fermfile { "${ip_proto}_${table}_${real_name}_0000":
      content => "\t\tpolicy ${policy};",
      require => Table["${table}_${ip_proto}"];
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

  fermfile {
    "${ip_proto}_${real_name}":
      content => $ip_proto ? {
        "v4" => "table ${real_name} {",
        "v6" => "domain ip6 table ${real_name} {",
      };
    "${ip_proto}_${real_name}_zzzz":
      content => "}";
  }
}

# Define: gen_ferm::fermfile
#
# Parameters:
#  ensure
#    Standard ensure
#  content
#    The content to enter into the firewall
#  exported
#    Define whether the file should be exported
#  customtag
#    The tag to give to the exported file
#
# Actions:
#  Creates a fragment of the firewall
#
# Depends:
#  gen_puppet
#
define gen_ferm::fermfile($content, $ensure=present, $exported=false, $customtag=false) {
  concat::add_content { $name:
    content    => $content,
    target     => "/etc/ferm/ferm.conf",
    ensure     => $ensure,
    exported   => $exported,
    contenttag => $customtag;
  }
}
