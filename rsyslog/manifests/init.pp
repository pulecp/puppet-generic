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
  package { "rsyslog":
    ensure => installed,
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

  file { "/etc/rsyslog.d/remote-logging-client.conf":
    content => template("rsyslog/client/remote-logging-client.conf"),
    require => Package["rsyslog"],
    notify => Service["rsyslog"],
  }
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

  file { "/etc/rsyslog.d/remote-logging-server.conf":
    content => template("rsyslog/server/remote-logging-server.conf"),
    require => Package["rsyslog"],
    notify => Service["rsyslog"],
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
