# Author: Kumina bv <support@kumina.nl>

# Class: gen_fail2ban
#
# Actions:
#  Set up fail2ban with several default setting from Debian (rewritten into this puppet manifest).
#
# Parameters:
#  ignoreip: Space separated list with CIDR notation IP addresses to ignore completely. Defaults to '127.0.0.0/8'.
#  email: If emails should be sent, this should be an email address. Defaults to false, which will not send emails.
#  bantime: The number of second we want to ban the offender. Defaults to 7200.
#
# Depends:
#  gen_puppet
#
class gen_fail2ban ($ignoreip='127.0.0.0/8', $email=false, $bantime='7200', $banaction='iptables-multiport') {
  kservice { 'fail2ban':
    pensure => latest,
  }

  concat { '/etc/fail2ban/jail.local':
    require => Package['fail2ban'],
    notify  => Exec['reload-fail2ban'];
  }

  concat::add_content { '000_default':
    content => template('gen_fail2ban/default'),
    target  => '/etc/fail2ban/jail.local';
  }
}

# Class: gen_fail2ban::dovecot
#
# Actions: Enable dovecot protections in fail2ban.
#
# Parameters:
#  maxretry: The number of failures we need to see before we will ban the IP address. Defaults to 3.
#
class gen_fail2ban::dovecot ($maxretry='3') {
  concat::add_content { 'dovecot':
    content => template('gen_fail2ban/dovecot'),
    target  => '/etc/fail2ban/jail.local';
  }

  if $lsbmajdistrelease < 7 {
    file { '/etc/fail2ban/filter.d/dovecot.local':
      content => template('gen_fail2ban/dovecot.local'),
      notify  => Exec['reload-fail2ban'];
    }
  }
}

# Class: gen_fail2ban::postfix
#
# Actions: Enable postfix protections in fail2ban.
#
# Parameters:
#  maxretry: The number of failures we need to see before we will ban the IP address. Defaults to 3.
#
class gen_fail2ban::postfix ($maxretry='3') {
  concat::add_content { 'postfix':
    content => template('gen_fail2ban/postfix'),
    target  => '/etc/fail2ban/jail.local';
  }
}

# Class: gen_fail2ban::ssh
#
# Actions: Enable ssh protections in fail2ban.
#
# Parameters:
#  maxretry: The number of failures we need to see before we will ban the IP address. Defaults to 3.
#
class gen_fail2ban::ssh ($maxretry='3') {
  concat::add_content { 'ssh':
    content => template('gen_fail2ban/ssh'),
    target  => '/etc/fail2ban/jail.local';
  }
}

# Class: gen_fail2ban::sasl
#
# Actions: Enable sasl protections in fail2ban.
#
# Parameters:
#  maxretry: The number of failures we need to see before we will ban the IP address. Defaults to 3.
#
class gen_fail2ban::sasl ($maxretry='3') {
  concat::add_content { 'sasl':
    content => template('gen_fail2ban/sasl'),
    target  => '/etc/fail2ban/jail.local';
  }
}
