# Author: Kumina bv <support@kumina.nl>

# Class: dhcp::server
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class dhcp::server {
  if versioncmp($lsbdistrelease, "6.0") < 0 {
    package { "dhcp3-server":; }

    service { "dhcp3-server":
      subscribe  => File["/etc/dhcp3/dhcpd.conf"],
      hasrestart => true,
      hasstatus  => true;
    }

    Package <| title == "dhcp3-common" |> {
      ensure => latest,
    }

    file { "/etc/dhcp3/dhcpd.conf":
      content => template("dhcp/dhcpd.conf");
    }
  }
  if versioncmp($lsbdistrelease, "6.0") >= 0 {
    package { "isc-dhcp-server":; }

    service { "isc-dhcp-server":
      ensure     => running,
      require    => Package["isc-dhcp-server"],
      subscribe  => File["/etc/dhcp/dhcpd.conf"],
      hasrestart => true,
      hasstatus  => true,
    }

    file { "/etc/dhcp/dhcpd.conf":
      require => Package["isc-dhcp-server"],
      content => template("dhcp/dhcpd.conf");
    }
  }
}
