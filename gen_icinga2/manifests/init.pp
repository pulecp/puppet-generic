class gen_icinga2::server {
  include gen_icinga2::common

  kservice { 'icinga2':; }
}

class gen_icinga2::classicui {
  include gen_icinga2::common

  gen_apt::preference { ['icinga-cgi', 'icinga-common']:; }

  package { 'icinga2-classicui':; }
}

class gen_icinga2::common {
  gen_apt::key { '34410682':
    content => template('gen_icinga2/34410682');
  }

  gen_apt::source { 'icinga2':
    comment      => 'Icinga2 repository.',
    sourcetype   => 'deb',
    uri          => 'http://packages.icinga.org/debian',
    distribution => 'icinga-wheezy',
    components   => 'main',
    key          => '34410682';
  }
}
