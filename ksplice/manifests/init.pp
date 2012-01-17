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
  kfile { "/var/cache/debconf/ksplice.preseed":
    source => "ksplice/ksplice.preseed";
  }

  # Install the ksplice package
  kpackage { "uptrack":
    ensure       => latest,
    responsefile => "/var/cache/debconf/ksplice.preseed",
    require      => Kfile["/var/cache/debconf/ksplice.preseed"],
    notify       => Exec["initial uptrack run"];
  }

  # Install the ksplice additional apps (includes nagios plugins)
  kpackage { "python-ksplice-uptrack":; }

  # Run the script when it's first installed
  exec { "initial uptrack run":
    command     => "/usr/sbin/uptrack-upgrade -y; exit 0",
    refreshonly => true,
    require     => Kfile["/etc/uptrack/uptrack.conf"],
  }

  # The modified configuration file
  Kfile <<| title == "/etc/uptrack/uptrack.conf" |>>

  # Set directory permissions so Nagios can read status
  kfile { "/var/cache/uptrack":
    require => Package["uptrack"];
  }
}
