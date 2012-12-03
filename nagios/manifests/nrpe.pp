# Author: Kumina bv <support@kumina.nl>

# Class: nagios::nrpe
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class nagios::nrpe {
  include nagios::nrpe::plugins

  define check($command) {
    file { "/etc/nagios/nrpe.d/$name.cfg":
      content => "command[check_$name]=$command\n",
      require => File["/etc/nagios/nrpe.d"],
    }
  }

  package { "nagios-nrpe-server":
    require => File['/etc/default/nagios-nrpe-server', '/etc/init.d/nagios-nrpe-server'];
  }

  # We're starting NRPE from inetd, to allow it to use tcpwrappers for
  # access control.
  service { "nagios-nrpe-server":
    ensure     => stopped,
    pattern    => "/usr/sbin/nrpe",
    hasrestart => true,
    require    => Package['nagios-nrpe-server'];
  }

  file {
    '/etc/default/nagios-nrpe-server':
      content => "INETD=1\n";
    '/etc/init.d/nagios-nrpe-server':
      content => template('nagios/nrpe/squeeze/nagios-nrpe-server');
  }

  package { "openbsd-inetd":; }

  service { "openbsd-inetd":
    ensure    => running,
    pattern   => "/usr/sbin/inetd",
    hasstatus => $lsbdistcodename ? {
      "lenny" => false,
      default => true,
    },
    require   => Package["openbsd-inetd"];
  }

  exec { "update-services-add-nrpe":
    command => "/bin/echo 'nrpe\t\t5666/tcp\t\t\t# Nagios NRPE' >> /etc/services",
    unless => "/bin/grep -q ^nrpe /etc/services",
  }

  # Need to bind to the IP address for this host only, if this is a
  # vserver.  Otherwise, just listen on all IP addresses, to simplify the
  # Nagios configuration.
  exec { "update-inetd-add-nrpe":
    command => $virtual ? {
      vserver => "/usr/sbin/update-inetd --add '$ipaddress:nrpe stream tcp nowait nagios /usr/sbin/nrpe -- -c /etc/nagios/nrpe.cfg --inetd'",
      default => "/usr/sbin/update-inetd --add 'nrpe stream tcp nowait nagios /usr/sbin/nrpe -- -c /etc/nagios/nrpe.cfg --inetd'",
    },
    unless => $virtual ? {
      vserver => "/bin/grep -E -q '^#?\s*(<off>#)?\s*$ipaddress:nrpe /etc/inetd.conf",
      default => "/bin/grep -E -q '^#?\s*(<off>#)?\s*nrpe' /etc/inetd.conf",
    },
    require => [Service["nagios-nrpe-server"], Exec["update-services-add-nrpe","update-inetd-remove-nrpe"]],
    notify => Service["openbsd-inetd"],
  }

  exec { "update-inetd-remove-nrpe":
    command => $virtual ? {
      vserver => "/usr/sbin/update-inetd --remove nrpe",
      default => "/usr/sbin/update-inetd --remove nrpe",
    },
    onlyif => $virtual ? {
      vserver => "/bin/grep -E -q '^#?\s*(<off>#)?.*tcpd /usr/sbin/nrpe' /etc/inetd.conf",
      default => "/bin/grep -E -q '^#?\s*(<off>#)?.*tcpd /usr/sbin/nrpe' /etc/inetd.conf",
    },
    require => [Service["nagios-nrpe-server"], Exec["update-services-add-nrpe"]],
    notify => Service["openbsd-inetd"],
  }

  exec { "update-inetd-enable-nrpe":
    command => virtual ? {
      vserver => "/usr/sbin/update-inetd --enable $ipaddress:nrpe",
      default => "/usr/sbin/update-inetd --enable nrpe",
    },
    unless => virtual ? {
      vserver => "/bin/grep -q ^$ipaddress:nrpe /etc/inetd.conf",
      default => "/bin/grep -q ^nrpe /etc/inetd.conf",
    },
    require => Exec["update-inetd-add-nrpe"],
    notify => Service["openbsd-inetd"],
  }

  exec { "/bin/echo 'nrpe: $nagios_nrpe_client' >> /etc/hosts.allow":
    unless => "/bin/grep -Fx 'nrpe: $nagios_nrpe_client' /etc/hosts.allow",
    require => Exec["update-inetd-enable-nrpe"],
  }

  file {
    "/etc/nagios/nrpe.cfg":
      content => $lsbdistcodename ? {
        'lenny' => template("nagios/nrpe/lenny/nrpe.cfg"),
        default => template("nagios/nrpe/squeeze/nrpe.cfg"),
      },
      require => Package["nagios-nrpe-server"];
    "/etc/nagios/nrpe.d":
      ensure  => directory,
      purge   => true,
      recurse => true,
      require => Package["nagios-nrpe-server"];
  }
}

# Class: nagios::nrpe::plugins
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class nagios::nrpe::plugins {
  include nagios::plugins


  package { "nagios-plugins-kumina":
    ensure => latest;
  }
}
