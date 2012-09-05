# Author: Kumina bv <support@kumina.nl>

# Class: gen_mailman
#
# Actions:
#  Set up Mailman
#
# Depends:
#  gen_puppet
#
class gen_mailman {
  kservice { 'mailman':
    hasstatus    => false,
    responsefile => '/var/cache/debconf/mailman.preseed';
  }

  file {
    '/var/cache/debconf/mailman.preseed':
      content => template('gen_mailman/mailman.preseed');
    '/etc/mailman/mm_cfg.py':
      content => template('gen_mailman/mm_cfg.py'),
      require => Package['mailman'],
      notify  => Exec['reload-mailman'];
  }
}
