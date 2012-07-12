# Author: Kumina bv <support@kumina.nl>

#
# Class: gen_munin
#
# Actions:
#  - Set pinning for munin on squeeze machines to backports
#
# Depends:
#  gen_apt
#
class gen_munin {
  if $lsbdistcodename == "squeeze" {
    gen_apt::preference { ["munin","munin-common","munin-doc","munin-java-plugins","munin-node","munin-plugins-core","munin-plugins-extra","munin-plugins-java"]:
      repo => "squeeze-backports";
    }
  }
}

# Class: gen_munin::server
#
# Actions:
#  - Install and configure munin
#
# Depends:
#  gen_puppet
#
class gen_munin::server {
  include gen_munin
  package { "munin":
    ensure => latest,
  }
}

# Class: gen_munin::client
#
# Actions:
#  - Install and configure munin-node
#
# Depends:
#  gen_puppet
#
class gen_munin::client {
  include gen_munin
  include gen_munin::client::plugin::defaults

  kservice { "munin-node":
    hasreload => false;
  }

  if $lsbdistcodename == 'lenny' {
    # in lenny we want our own package
    gen_apt::preference { "munin-plugins-extra":
      repo => "lenny-kumina";
    }
  } else {
    package {"munin-plugins-core":
      ensure => latest;
    }
  }

  package{ ["munin-plugins-extra","libnet-cidr-perl"]:
    ensure => latest;
  }

  concat { '/etc/munin/munin-node.conf':
    notify  => Exec['reload-munin-node'],
    require => Package['munin-node'];
  }

  concat::add_content { '/etc/munin/munin-node.conf base':
    target  => '/etc/munin/munin-node.conf',
    content => template('gen_munin/client/munin-node.conf.base');
  }
  Concat::Add_content <<| tag == "munin-node.conf_server_allows_${environment}" |>>

  if $munin_proxy {
    $munin_template = "gen_munin/server/munin.conf_client_with_proxy"
  } else {
    $real_ipaddress = $external_ipaddress ? {
      undef => $ipaddress,
      false => $ipaddress,
      default => $external_ipaddress,
    }
    $munin_template = "gen_munin/server/munin.conf_client"
  }

  @@file { "/etc/munin/conf/${fqdn}":
    content => template($munin_template),
    require => File["/etc/munin/conf"],
    tag     => "munin_client_${environment}";
  }

  # Fixed in 2.0.1, see: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=675593
  file { '/var/lib/munin/plugin-state':
    ensure => directory,
    owner  => 'munin',
    group  => 'munin',
    mode   => 775;
  }
}

#
# Define: gen_munin::environment
#
# Actions:
#  - Import all exported server config from machines in $environment
#  - Export client config to allow the server access
#
# Depends:
#  gen_munin
#
define gen_munin::environment {
  File <<| tag == "munin_client_${name}" |>> {}

  @@concat::add_content { "/etc/munin/munin-node.conf server ${fqdn} for env ${name}":
    content => "cidr_allow ${ipaddress}/32\n",
    target  => '/etc/munin/munin-node.conf',
    tag     => "munin-node.conf_server_allows_${name}";
  }
}

#
# Class: gen_munin::client::plugin::defaults
#
# Actions:
#  - Add many default plugins
#
# Depends:
#  gen_munin::client
#
class gen_munin::client::plugin::defaults {
  if $lsbdistcodename == 'lenny' {
    include "gen_munin::client::plugin::defaults::lenny"
  } else {
    include 'gen_munin::client::plugin::defaults::generic'
  }

  $ifs = split($interfaces, ",")
  gen_munin::client::plugin::interfaces { $ifs:; }

  gen_munin::client::plugin {
    "cpu":;
    "df":;
    "df_inode":;
    "entropy":;
    "forks":;
    "interrupts":;
    "iostat":;
    "irqstats":;
    "load":;
    "memory":;
    "open_files":;
    "open_inodes":;
    "processes":;
    "swap":;
    "vmstat":;
  }
}

class gen_munin::client::plugin::defaults::lenny {
  # nothing :D
}

class gen_munin::client::plugin::defaults::generic {
  gen_munin::client::plugin {
    "diskstats":;
    "fw_conntrack":;
    "fw_forwarded_local":;
    "fw_packets":;
    "iostat_ios":;
    "proc_pri":;
    "threads":;
    "uptime":;
    "users":;
  }
}

#
# Define: gen_munin::client::plugin::interfaces
#
# Actions:
#  Create plugin link for all network interfaces (called from gen_munin::client::plugin::default)
#
# Depends:
#  gen_munin::client
#
define gen_munin::client::plugin::interfaces {
  if $name != "lo" {
    gen_munin::client::plugin {
      "if_${name}":
        script => "if_";
      "if_err_${name}":
        script => "if_err_";
    }
  }
}

#
# Define: gen_munin::client::plugin
#
# Actions:
#  - Create a symlink /etc/munin/plugins/$name to a munin plugin and restart the munin-node daemon
#
# Parameters:
#  ensure:
#   What do you think?
#  script_path:
#   The path where the plugin is located
#  script:
#   The name of the script in $script_path. If unset, $name is used
#
# Depends:
#  gen_munin::client
#
define gen_munin::client::plugin ($ensure='present', $script_path='/usr/share/munin/plugins', $script=false) {
  $plugin_path = $script ? {
    false   => "${script_path}/${name}",
    default => "${script_path}/${script}"
  }

  file { "/etc/munin/plugins/${name}":
    ensure  => $ensure ? {
      'present' => link,
      'absent' => 'absent',
    },
    target  => $plugin_path,
    # Legacy, if all envs use gen_munin, change this to notify  => Exec["reload-munin-node"]
    notify  => defined(Class["gen_munin::client"]) ? {
      true    => Exec["reload-munin-node"],
      default => Service["munin-node"],
    },
    require => Package["munin-node"],
  }
}

#
# Define: gen_munin::client::plugin::config
#
# Actions:
#  - Create config for munin plugin and restart the munin-node daemon
#
# Parameters:
#  content:
#   The config
#  section:
#   The ini header (name of the plugin). If unset, $name is used
#  ensure:
#   What do you think
#
# Depends:
#  gen_munin::client
#
define gen_munin::client::plugin::config($content, $section=false, $ensure='present') {
  file { "/etc/munin/plugin-conf.d/${name}":
    ensure  => $ensure,
    content => $section ? {
      false   => "[${name}]\n${content}\n",
      default => "[${section}]\n${content}\n",
    },
    require => Package["munin-node"],
    # Legacy, if all envs use gen_munin, change this to notify  => Exec["reload-munin-node"]
    notify  => defined(Class["gen_munin::client"]) ? {
      true    => Exec["reload-munin-node"],
      default => Service["munin-node"],
    },
  }
}
