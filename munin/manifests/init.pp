# Author: Kumina bv <support@kumina.nl>

# Class: munin::client
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class munin::client {
  define plugin($ensure='present', $script_path='/usr/share/munin/plugins', $script=false) {
    if $script {
      $plugin_path = "$script_path/$script"
    } else {
      $plugin_path = "$script_path/$name"
    }

    kfile { "/etc/munin/plugins/$name":
      ensure => $ensure ? {
        'present' => $plugin_path,
        'absent' => 'absent',
      },
      notify => Service["munin-node"],
      require => [Package["munin-node"], File["/usr/local/share/munin/plugins"]],
    }
  }

  define plugin::config($content, $section=false, $ensure='present') {
    kfile { "/etc/munin/plugin-conf.d/$name":
      ensure => $ensure,
      content => $section ? {
        false => "[${name}]\n${content}\n",
        default => "[${section}]\n${content}\n",
      },
      require => Package["munin-node"],
      notify => Service["munin-node"],
    }
  }

  kpackage { "munin-node":; }

  if versioncmp($lsbdistrelease,"5.0") >= 0 { # in Lenny and above we have the extra-plugins in a package
    if versioncmp($lsbdistrelease, "6") < 0 { # in lenny we want our own package
      gen_apt::preference { "munin-plugins-extra":
        repo => "lenny-kumina";
      }
    }

    kpackage { ["munin-plugins-extra", "munin-plugins-kumina"]:
      ensure => latest;
    }
  }

  # Extra plugins
  kfile { "/usr/local/share/munin/plugins":
    recurse => true,
    source => "munin/client/plugins",
    group => "staff",
    mode => 755;
  }

  # Munin node configuration
  kfile { "/etc/munin/munin-node.conf":
    content => template("munin/client/munin-node.conf"),
    require => Package["munin-node"],
  }

  service { "munin-node":
    subscribe => File["/etc/munin/munin-node.conf"],
    require => [Package["munin-node"], File["/etc/munin/munin-node.conf"]],
    hasrestart => true,
    ensure => running,
  }

  kfile {  "/usr/local/share/munin":
    ensure => directory,
    group => "staff";
  }

  # This has only been tested on squeeze
  if versioncmp($lsbdistrelease, "6") >= 0 {
    # This makes sure the plugins directory only contains files we've actually deployed
    kfile { "/etc/munin/plugins":
      ensure  => directory,
      purge   => true,
      recurse => true,
      force   => true,
    }

    include munin::client::default_plugins
  }

  # Configs needed for JMX monitoring. Not needed everywhere, but roll out
  # nonetheless.
  kfile { "/etc/munin/jmx_config":
    recurse => true,
    source  => "munin/client/configs",
    group   => "staff",
    mode    => 755;
  }
}

# Class: munin::server
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class munin::server {
  package { ["munin"]:
    ensure => installed,
  }

  kfile { "/etc/munin/munin.conf":
    source => "munin/server/munin.conf",
    require => Package["munin"],
  }

  # Needed when munin-graph runs as a CGI script
  package { "libdate-manip-perl":
    ensure => installed,
  }

  kfile {
    "/var/log/munin":
      ensure => directory,
      owner => "munin",
      mode => 771;
    "/var/log/munin/munin-graph.log":
      owner => "munin",
      group => "www-data",
      mode  => 660;
    "/etc/logrotate.d/munin":
      source => "munin/server/logrotate.d/munin";
  }
}

# Class: munin::client::default_plugins
#
# Actions:
#  Setup the plugins that Munin wants by default
#
# Depends:
#  gen_puppet
#  munin::client::plugin
#
class munin::client::default_plugins {
  munin::client::plugin {
    "df_inode":;
    "vmstat":;
    "load":;
    "forks":;
    "swap":;
    "processes":;
    "open_inodes":;
    "irqstats":;
    "iostat":;
    "memory":;
    "interrupts":;
    "open_files":;
    "entropy":;
    "cpu":;
    "df":;
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

  # Use the fact interfaces for setting up interfaces.
  $ifs = split($interfaces, ",")
  munin::client::setup_interface { $ifs:; }
}

# Define: munin::client::setup_interface
#
# Actions:
#  Adds plugins to munin for a specific interface
#
# Depends:
#  gen_puppet
#  munin::client::plugin
#
define munin::client::setup_interface {
  # We never want to setup stuff for lo, but this define is probably
  # called via munin::client::setup_interfaces { $interfaces:; }
  if $name != "lo" {
    munin::client::plugin {
      "if_${name}":
        script => "if_";
      "if_err_${name}":
        script => "if_err_";
    }
  }
}
