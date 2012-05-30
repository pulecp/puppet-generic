# Author: Kumina bv <support@kumina.nl>

# Copyright (C) 2010 Kumina bv, Tim Stoop <tim@kumina.nl>
# This works is published under the Creative Commons Attribution-Share
# Alike 3.0 Unported license - http://creativecommons.org/licenses/by-sa/3.0/
# See LICENSE for the full legal text.

# Class: ksplice
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class ksplice {
  # Add the source repo
  gen_apt::source { "ksplice":
    uri          => "http://www.ksplice.com/apt",
    distribution => "${lsbdistcodename}",
    components   => ["ksplice"],
  }

  # Preseed the ksplice package
  file { "/var/cache/debconf/ksplice.preseed":
    content => template("ksplice/ksplice.preseed");
  }

  # Install the ksplice package
  package { "uptrack":
    ensure       => latest,
    responsefile => "/var/cache/debconf/ksplice.preseed",
    require      => File["/var/cache/debconf/ksplice.preseed"],
    notify       => Exec["initial uptrack run"];
  }

  # Install the ksplice additional apps (includes nagios plugins)
  package { "python-ksplice-uptrack":
    ensure => latest,
  }

  # Run the script when it's first installed
  exec { "initial uptrack run":
    command     => "/usr/sbin/uptrack-upgrade -y; exit 0",
    refreshonly => true,
    require     => File["/etc/uptrack/uptrack.conf"],
  }

  # The modified configuration file
  File <<| title == "/etc/uptrack/uptrack.conf" |>>

  # Set directory permissions so Nagios can read status
  file { "/var/cache/uptrack":
    require => Package["uptrack"];
  }
}

define ksplice::proxy ($proxy) {
  kaugeas { $name:
    file    => '/etc/uptrack/uptrack.conf',
    # Puppet.lns is somesort of wildcard Ini lens :/
    lens    => 'Puppet.lns',
    changes => "set Network/https_proxy ${proxy}",
    require => File['/etc/uptrack/uptrack.conf'];
  }
}
