# Author: Kumina bv <support@kumina.nl>

# Class: gen_davfs
#
# Actions:
#  Sets up davfs
#
class gen_davfs {
  package { 'davfs2':
    ensure => latest;
  }

  file { '/etc/davfs2/davfs2.conf':
    content => 'ask_auth 0',
    require => Package['davfs2'];
  }
}
