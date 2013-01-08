# Author: Kumina bv <support@kumina.nl>

# Class: gen_puppet::puppetdb
#
# Actions:
#  Setup puppetdb from the Kumina repo.
#
# Depends:
#
class gen_puppet::puppetdb {
  package { ['puppetdb','puppetdb-terminus']:
    ensure  => latest,
  }

  file { '/etc/puppet/routes.yaml':
    content => template('gen_puppet/puppetdb/routes.yaml'),
    require => Package['puppetmaster'];
  }
}

# Class: gen_puppet::puppetdb::conf
#
# Actions:
#  Setup default config file.
#
# Depends:
#  gen_puppet
#
class gen_puppet::puppetdb::conf {
  # Setup the default config file
  concat { '/etc/puppet/puppetdb.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package["puppetdb"];
  }

  # Already define all the sections
  concat::add_content {
    "main section in puppetdb.conf":
      target  => '/etc/puppet/puppetdb.conf',
      content => "[main]",
      order   => '10';
  }
}

# Define: gen_puppet::puppetdb::set_config
#
# Parameters:
#  configfile
#    The configfile to change. Defaults to /etc/puppet/puppetdb.conf.
#  var
#    The variable name to set. Defaults to the name of the resource, $name.
#  value
#    The value to set the variable to. Required option.
#
# Actions:
#  Add the config to the correct file.
#
# Depends:
#  gen_puppet::set_config
#  gen_puppet::puppetdb::conf
#
# Todo:
#  Rewrite to use kaugeas instead of concat.
#
define gen_puppet::puppetdb::set_config ($value, $configfile = '/etc/puppet/puppetdb.conf', $var = $name) {
  include gen_puppet::puppetdb::conf

  gen_puppet::set_config { "${name} in puppetdb":
    configfile => $configfile,
    var        => $var,
    value      => $value,
    order      => 15,
  }
}
