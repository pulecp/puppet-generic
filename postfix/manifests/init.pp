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
class postfix($relayhost=false, $myhostname=$fqdn, $mynetworks="127.0.0.0/8 [::1]/128", $mydestination=false, $smtp_recipient=false, $mode=false) {
  $real_smtp_recipient = $mode ? {
    false                 => $smtp_recipient,
    /(primary|secondary)/ => true,
  }
  $real_mydestination = $mode ? {
    false                 => $mydestination,
    /(primary|secondary)/ => $mydestination ? {
      false   => $mode,
      default => "${mode}, ${mydestination}",
    },
  }
  $real_relayhost = $mode ? {
    false                 => $relayhost,
    /(primary|secondary)/ => false,
  }

  package {
    "postfix":;
    "nullmailer":
      ensure => absent;
  }

  service { "postfix":
    enable     => true,
    hasrestart => true,
    pattern    => "/usr/lib/postfix/master",
    require    => [Package["postfix"],File["/etc/ssl/certs"]],
    subscribe  => File["/etc/ssl/certs"];
  }

  file {
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

define postfix::alias($ensure="present") {
  line { $name:
    ensure => $ensure,
    file   => "/etc/aliases",
    notify => Exec["newaliases"];
  }
}
