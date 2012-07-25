# Author: Kumina bv <support@kumina.nl>

import "concat.pp"
import "ekfile.pp"
import "kaugeas.pp"
import "kcron.pp"
import "kservice.pp"
import "line.pp"
import "setfacl.pp"

# Actual puppet modules
import "queue.pp"
import "master.pp"

File {
  owner  => "root",
  group  => "root",
  mode   => 644,
  backup => false,
}

# Class: gen_puppet
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class gen_puppet {
  include gen_puppet::puppet_conf
  include gen_base::augeas
  include gen_base::facter

  package {
    "puppet-common":
      ensure => latest;
    "puppet":
      ensure => latest,
      notify => Exec["reload-puppet"];
    "checkpuppet":
      ensure => purged;
  }

  exec { "reload-puppet":
    command     => "/bin/true",
    refreshonly => true,
    require     => Package["puppet-common"],
  }
}

# Class: gen_puppet::puppet_conf
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class gen_puppet::puppet_conf {
  # Setup the default config file
  concat { '/etc/puppet/puppet.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package["puppet-common"],
    notify  => Exec["reload-puppet"],
  }

  # Already define all the sections
  concat::add_content {
    "main section":
      target  => '/etc/puppet/puppet.conf',
      content => "[main]",
      order   => '10';
    "agent section":
      target  => '/etc/puppet/puppet.conf',
      content => "\n[agent]",
      order   => '20';
    "master section":
      target  => '/etc/puppet/puppet.conf',
      content => "\n[master]",
      order   => '30';
  }
}

# Define: gen_puppet::set_config
#
# Parameters:
#  configfile
#    The configfile to change. Defaults to /etc/puppet/puppet.conf.
#  section
#    The inifile section to put this directive in. Can be one of 'main','agent' or 'master'. Defaults to 'main'.
#  order
#    If an order is needed, add a priority. Check source to see what makes sense. Defaults to false.
#  var
#    The variable name to set. Defaults to the name of the resource, $name.
#  value
#    The value to set the variable to. Required option.
#
# Actions:
#  Add the config to the correct file.
#
# Depends:
#  gen_puppet::concat
#  gen_puppet
#
# Todo:
#  Rewrite to use kaugeas instead of concat.
#
define gen_puppet::set_config ($value, $configfile = '/etc/puppet/puppet.conf', $section = 'main', $order = false, $var = false) {
  # If no variable name is set, use the name
  if $var {
    $real_var = $var
  } else {
    $real_var = $name
  }

  # If order is set, don't use section
  if $order {
    $real_order = $order
  } else {
    # Based on section, set order
    $real_order = $section ? {
      'main'   => "15",
      'agent'  => "25",
      'master' => "35",
      default  => fail("No order given and no known section given."),
    }
  }

  concat::add_content { $name:
    target  => $configfile,
    content => "${real_var} = ${value}",
    order   => $real_order,
  }
}
