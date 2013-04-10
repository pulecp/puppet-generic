# Author: Kumina bv <support@kumina.nl>

# Class: gen_newrelic
#
# Actions:
#  Set up NewRelic.
#
# Parameters:
#  key: The key for NewRelic.
#
# Depends:
#  gen_apt
#
class gen_newrelic ($key) {
  gen_apt::source { 'newrelic':
    uri          => 'http://apt.newrelic.com/debian/',
    distribution => 'newrelic',
    components   => 'non-free';
  }

  gen_apt::key { '548C16BF':
    content => template('gen_newrelic/newrelic-key');
  }

  package { 'newrelic-sysmond':
    ensure => latest,
  }

  file { '/etc/newrelic/nrsysmond.cfg':
    content => template('gen_newrelic/nrsysmond.cfg'),
    require => Package['newrelic-sysmond'],
    notify  => Service['newrelic-sysmond'];
  }

  service { 'newrelic-sysmond':
    require   => Package['newrelic-sysmond'],
    ensure    => running,
    hasstatus => true,
  }
}

# Class: gen_newrelic::php
#
# Actions:
#  Setup the PHP daemon for NewRelic.
#
# Depends:
#  gen_newrelic
#
class gen_newrelic::php {
  $key = $gen_newrelic::key

  package {
    'newrelic-daemon':
      ensure => latest;
    ['newrelic-php5','newrelic-php5-common']:
      ensure => latest,
      notify => Exec['reload-apache2'],
      require => File['/var/log/newrelic/newrelic-daemon.log'];
  }

  file {
    '/var/log/newrelic/newrelic-daemon.log':
      owner   => 'newrelic',
      group   => 'www-data',
      mode    => 660,
      require => Package['newrelic-daemon'];
    '/etc/php5/conf.d/newrelic.ini':
      content => template('gen_newrelic/php.ini'),
      require => Package['newrelic-php5'],
      notify  => Exec['reload-apache2'];
  }
}
