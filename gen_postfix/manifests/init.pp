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
class gen_postfix ($relayhost = false, $myhostname = $fqdn, $mynetworks = '127.0.0.0/8 [::1]/128', $mydestination = false, $smtp_recipient = false, $mode = false, $always_bcc = false) {
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

  package { 'nullmailer':
    ensure => absent;
  }

  kservice { 'postfix':
    pattern => '/usr/lib/postfix/master';
  }

  file { '/etc/postfix/main.cf':
    content => template('gen_postfix/main.cf'),
    require => Package['postfix'],
    notify  => Service['postfix'];
  }

  exec { 'newaliases':
    refreshonly => true,
    path        => '/usr/bin';
  }
}

define gen_postfix::alias($ensure='present') {
  line { $name:
    ensure => $ensure,
    file   => '/etc/aliases',
    notify => Exec['newaliases'];
  }
}
