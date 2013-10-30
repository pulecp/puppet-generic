#
# Class: gen_ngircd
#
# Actions: install ngircd and set up config
#
# Parameters:
#  servername: the name to display to clients
#  serverinfo: a hash containing one or more of the following fields: Info, AdminInfo1, AdminInfo2, AdminEMail (see the comments in the sample config for the meanings: http://ngircd.barton.de/doc/sample-ngircd.conf)
#  listen: array of IPv4 addresses to bind to (false means: bind on everything)
#  listen6: array of IPv6 addresses to bind to (false means: bind on everything)
#  ports: array of ports to bind to
#  motd: String with the full MOTD content
#  ssl_cert: the name of the ssl-cert/key (without .key/.pem)
#  ssl_dh_params: the Diffie-Hellman parameters for SSL
#  ssl_ports: array of ports to bind to for ssl
#
class gen_ngircd ($servername=$fqdn, $serverinfo=false, $listen=[$ipaddress], $listen6=false, $ports=['6667'], $motd=false, $ssl_cert=false, $ssl_dh_params=false, $ssl_ports=false) {
  kservice { 'ngircd':; }

  concat { '/etc/ngircd/ngircd.conf':
    require => Package['ngircd'],
    notify  => Exec['reload-ngircd'];
  }

  concat::add_content { 'ngircd.conf global':
    content => template('gen_ngircd/global'),
    order   => 10,
    target  => '/etc/ngircd/ngircd.conf';
  }
}

#
# Define: gen_ngircd::operator
#
# Actions: Add an operator to IRC
#
# Parameters:
#  password: The password for the user
#
define gen_ngircd::operator ($password) {
  concat::add_content { "ngircd.conf operator ${name}":
    content => template('gen_ircd/operator'),
    order   => 20,
    target  => '/etc/ngircd/ngircd.conf';
  }
}

#
# Define: gen_ngircd::operator
#
# Actions: Add an channel to IRC
#
define gen_ngircd::channel () {
  concat::add_content { "ngircd.conf channel ${name}":
    content => template('gen_ircd/channel'),
    order   => 30,
    target  => '/etc/ngircd/ngircd.conf';
  }
}
