# Author: Kumina bv <support@kumina.nl>

# Class: postfix
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class postfix {
  kpackage { "postfix":; }

  service { "postfix":
    enable     => true,
    hasrestart => true,
    pattern    => "/usr/lib/postfix/master",
    require    => Package["postfix"];
  }

  kfile {
    "/etc/postfix/main.cf":
      content => template("postfix/main.cf"),
      require => Package["postfix"],
      notify  => Service["postfix"];
    "/var/spool/postfix/dovecot":
      ensure  => directory,
      owner   => "postfix",
      group   => "mail",
      require => Package["postfix"];
  }

  exec { "newaliases":
    refreshonly => true,
    path        => "/usr/bin";
  }
}
