# Author: Kumina bv <support@kumina.nl>

# Class: dovecot::common
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class dovecot::common {
  package {
    "dovecot-common":
      ensure => installed,
  }

  service {
    "dovecot":
      ensure => running,
      require => Package["dovecot-common"],
  }

  kfile {
    "/etc/dovecot/dovecot.conf":
      source => "dovecot/dovecot/dovecot.conf",
      require => Package["dovecot-common"],
      notify => Service["dovecot"];
    "/etc/dovecot/dovecot-ldap.conf":
      source => "dovecot/dovecot/dovecot-ldap.conf",
      mode => 600,
      require => Package["dovecot-common"],
      notify => Service["dovecot"];
    "/etc/dovecot/dovecot-sql.conf":
      source => "dovecot/dovecot/dovecot-sql.conf",
      mode => 600,
      require => Package["dovecot-common"],
      notify => Service["dovecot"];
  }

  user {
    "dovecot-auth":
      comment => "Dovecot mail server",
      ensure => present,
      gid => "nogroup",
      uid => 200,
      membership => minimum,
      shell => "/bin/false",
      home => "/usr/lib/dovecot",
      require => Package["dovecot-common"];
  }
}

# Class: dovecot::imap
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class dovecot::imap inherits dovecot::common {
  package {
    "dovecot-imapd":
      ensure => installed,
      require => Package["dovecot-common"],
  }
}

# Class: dovecot::pop3
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class dovecot::pop3 inherits dovecot::common {
  package {
    "dovecot-pop3d":
      ensure => installed,
      require => Package["dovecot-common"],
  }
}
