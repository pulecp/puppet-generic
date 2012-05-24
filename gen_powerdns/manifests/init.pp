# Class: gen_powerdns
#
# Actions: Install powerdns authoritative server and configure the generic part of th config
#
# Parameters:
#  localaddress The IPv4 Address the server should bind to.
#
# Depends:
#  gen_puppet
#
class gen_powerdns ($localaddress='0.0.0.0') {
  kservice { 'pdns':
    package => 'pdns-server';
  }

  concat { '/etc/powerdns/pdns.conf':
    require => Package['pdns-server'],
    mode    => 640,
    notify  => Exec['reload-pdns'];
  }

  concat::add_content { 'PowerDNS Default settings':
    target => '/etc/powerdns/pdns.conf',
    content => template('gen_powerdns/default');
  }
}

# Define: gen_powerdns::backend::mysql
#
# Actions: Install the PowerDNS MySQL backend and configure the PowerDNS server to use it.
#
# Parameters:
#  db_host     The host where the database runs
#  db_name     The name of the database
#  db_user     The user for the database
#  db_password The password for the user
#
# Depends:
#  gen_puppet
#  gen_powerdns
#
define gen_powerdns::backend::mysql ($db_host='localhost', $db_name='pdns', $db_user='pdns', $db_password='pdns'){
  package { 'pdns-backend-mysql':
    ensure  => latest,
    require => Package['pdns-server'];
  }

  file { '/etc/powerdns/pdns.d/mysql.conf':
    ensure  => absent,
    require => Package['pdns-backend-mysql'];
  }

  concat::add_content { 'PowerDNS MySQL settings':
    target  => '/etc/powerdns/pdns.conf',
    content => template('gen_powerdns/mysql');
  }
}
