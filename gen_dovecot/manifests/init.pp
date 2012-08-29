# Author: Kumina bv <support@kumina.nl>

# Class: dovecot::common
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class gen_dovecot {
  kservice { "dovecot":
    pname  => 'dovecot-common';
  }

#  file {
#    "/etc/dovecot/dovecot.conf":
#      content => template("dovecot/dovecot.conf"),
#      require => Package["dovecot-common"],
#      notify  => Service["dovecot"];
#    "/etc/dovecot/dovecot-ldap.conf":
#      content => template("dovecot/dovecot-ldap.conf"),
#      mode    => 600,
#      require => Package["dovecot-common"],
#      notify  => Service["dovecot"];
#    "/etc/dovecot/dovecot-sql.conf":
#      content => template("dovecot/dovecot-sql.conf"),
#      mode    => 600,
#      require => Package["dovecot-common"],
#      notify  => Service["dovecot"];
#  }

  user { "dovecot-auth":
    comment => "Dovecot mail server",
    ensure  => present,
    gid     => "nogroup",
    uid     => 200,
    shell   => "/bin/false",
    home    => "/usr/lib/dovecot",
    require => Package["dovecot-common"];
  }
}

# Class: dovecot::imap
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class gen_dovecot::imap {
  include gen_dovecot

  package { "dovecot-imapd":
    require => Package["dovecot-common"];
  }
}

# Class: dovecot::pop3
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class gen_dovecot::pop3 {
  include dovecot

  package { "dovecot-pop3d":
    require => Package["dovecot-common"];
  }
}
