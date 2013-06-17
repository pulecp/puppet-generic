# Author: Kumina bv <support@kumina.nl>

# Class: gen_openstack
#
# Actions:
#  Set up OpenStack common stuff.
#
# Depends:
#  gen_apt
#
class gen_openstack {
  package { 'nova-api':
    ensure => latest;
  }
}

# Class: gen_openstack::client
#
# Actions:
#  Setup a server to act as a client to OpenStack.
#
class gen_openstack::client {
  include gen_openstack

  package { ['nova-compute','nova-network']:
    ensure => latest;
  }
}

# Class: gen_openstack::server
#
# Actions:
#  Setup a machine to act as a server to openstack nodes.
#
#
class gen_openstack::server {
  include gen_openstack

  package { ['nova-scheduler','nova-conductor','glance','keystone','openstack-dashboard']:
    require => Package['mysql-server'],
    ensure  => latest;
  }
}
