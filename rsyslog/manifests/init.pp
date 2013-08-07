# Author: Kumina bv <support@kumina.nl>

# Class: rsyslog::common
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class rsyslog::common {
  if $lsbdistcodename == 'wheezy' {
    package { ['rsyslog','rsyslog-gnutls']:
      ensure => latest,
      notify => Service['rsyslog'],
    }
  } else {
    package {
      'rsyslog':
        ensure => latest,
        notify => Service['rsyslog'];
      'rsyslog-gnutls':
        ensure => absent,
        notify => Service['rsyslog'];
    }
  }

  file { '/var/spool/rsyslog':
    ensure => directory,
    notify => Service['rsyslog'];
  }

  service { "rsyslog":
    enable => true,
    require => Package["rsyslog"],
  }
}

# Class: rsyslog::client
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class rsyslog::client {
  include rsyslog::common

  $pemfile = "${fqdn}.pem"

  file {
    '/etc/rsyslog.d/forwardfile-logformat.conf':
      ensure  => absent,
      content => template('rsyslog/client/forwardfile-logformat.conf'),
      require => Package['rsyslog'],
      notify => Service['rsyslog'];
    '/etc/rsyslog.d/enable-ssl-puppet-certs.conf':
      ensure  => absent,
      content => template('rsyslog/client/enable-ssl-puppet-certs.conf'),
      require => Package['rsyslog'],
      notify => Service['rsyslog'];
  }

  # We import this so we can change the server to use
  File <<| title == '/etc/rsyslog.d/remote-logging-client.conf' |>>
}

# Class: rsyslog::server
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class rsyslog::server {
  include rsyslog::common

  $pemfile = "${fqdn}.pem"

  file {
    "/etc/rsyslog.d/remote-logging-server.conf":
      content => template("rsyslog/server/remote-logging-server.conf"),
      require => [Package["rsyslog"],File['/var/log/external']],
      notify  => Service["rsyslog"];
    '/etc/rsyslog.d/enable-ssl-puppet-certs.conf':
      content => template('rsyslog/server/enable-ssl-puppet-certs.conf'),
      require => Package["rsyslog"],
      notify  => Service["rsyslog"];
  }

  # Make sure the directory actually exists
  file { "/var/log/external":
    ensure => directory,
  }

  # Export the client configuration for remote logging
  @@file { '/etc/rsyslog.d/remote-logging-client.conf':
      content => template('rsyslog/server/remote-logging-client.conf'),
      require => Package['rsyslog'],
      notify => Service['rsyslog'];
  }
}

# Class: rsyslog::mysql
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class rsyslog::mysql {
  package { "rsyslog-mysql":
    ensure => installed;
  }

  file { "/etc/rsyslog.d/mysql.conf":
    content => template("rsyslog/server/mysql.conf"),
    require => Package["rsyslog-mysql"],
    notify  => Service["rsyslog"];
  }
}
