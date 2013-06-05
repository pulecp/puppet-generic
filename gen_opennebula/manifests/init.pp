# Author: Kumina bv <support@kumina.nl>

# Class: gen_opennebula
#
# Actions:
#  Set up OpenNebula
#
# Depends:
#  gen_apt
#
class gen_opennebula ($private_key, $public_key) {
  gen_apt::preference { ['opennebula','opennebula-common','opennebula-tools','ruby-opennebula','opennebula-ozones','opennebula-sunstone','libopennebula-java','libopennebula-java-doc',
                         'opennebula-node']:
    repo => "${lsbdistcodename}-kumina";
  }

  package { 'opennebula-common':
    ensure => latest,
  }

  user { 'oneadmin':
    require => Package['opennebula-common'];
  }

  file {
    '/var/lib/one/.ssh':
      ensure  => directory,
      owner   => 'oneadmin',
      group   => 'cloud',
      mode    => 700,
      require => Package['opennebula-common'];
    '/var/lib/one/.ssh/authorized_keys':
      content => $public_key,
      owner   => 'oneadmin',
      group   => 'cloud',
      mode    => 600;
    '/var/lib/one/.ssh/id_rsa':
      source  => "puppet:///modules/${private_key}",
      owner   => 'oneadmin',
      group   => 'cloud',
      mode    => 600;
    '/var/lib/one/.ssh/config':
      content => "ConnectTimeout 5\nHost *\n  StrictHostKeyChecking no\n",
      owner   => 'oneadmin',
      group   => 'cloud',
      mode    => 640;
  }

  # TODO setup openvswitch, but it seems to require a module to be built on installation?
}

# Class: gen_opennebula::client
#
# Actions:
#  Setup a server to act as a client to OpenNebula.
#
class gen_opennebula::client ($public_key, $private_key) {
  class { 'gen_opennebula':
    public_key => $public_key,
    private_key => $private_key;
  }

  package { 'opennebula-node':
    ensure => latest,
  }

  User <| title == 'oneadmin' |> {
    groups => ['adm'],
  }
}

# Class: gen_opennebula::server
#
# Actions:
#  Setup a machine to act as a server to opennebula nodes.
#
# Parameters:
#  private_key: The location of the private key. This will be transfered as a file resource, puppet:///modules/ is already added in front of it.
#  one_password: The password for the oneadmin user.
#
class gen_opennebula::server($private_key, $public_key, $one_password, $datastore='/var/lib/one/datastores', $script_remote_dir='/var/lib/one/remotes') {
  class { 'gen_opennebula':
    public_key => $public_key,
    private_key => $private_key;
  }

  package { ['opennebula','opennebula-tools','ruby-opennebula']:
    ensure => latest,
  }

  file {
    '/var/lib/one/.one/one_auth':
      content => "oneadmin:${one_password}",
      owner   => 'oneadmin',
      group   => 'cloud',
      mode    => 600,
      require => Package['opennebula-common'];
    '/etc/one/oned.conf':
      notify  => Service['opennebula'],
      content => template('gen_opennebula/oned.conf');
  }

  service { 'opennebula':
    require    => Package['opennebula'],
    ensure     => running,
    hasrestart => true,
  }
}

class gen_opennebula::sunstone ($password) {
  include gen_opennebula

  package { 'opennebula-sunstone':
    ensure => latest,
  }

  service { 'opennebula-sunstone':
    ensure     => running,
    hasrestart => true,
    hasstatus  => false,
    pattern    => 'ruby /usr/share/opennebula/sunstone/sunstone-server.rb',
    require    => Package['opennebula-sunstone'];
  }

  file {
    '/etc/one/sunstone-server.conf':
      notify  => Service['opennebula-sunstone'],
      content => template('gen_opennebula/sunstone-server.conf');
    '/var/lib/one/.one/sunstone_auth':
      content => "oneadmin:${one_password}",
      owner   => 'oneadmin',
      group   => 'cloud',
      mode    => 600,
      require => Package['opennebula-common'];
  }
}
