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
    kpackage { "dhcp3-server":; }

    service { "dhcp3-server":
      subscribe  => File["/etc/dhcp3/dhcpd.conf"],
      hasrestart => true,
      hasstatus  => true;
    }

    Kpackage <| title == "dhcp3-common" |> {
      ensure => latest,
    }

    kfile { "/etc/dhcp3/dhcpd.conf":
      content => template("dhcp/dhcpd.conf");
    }
  }
  if versioncmp($lsbdistrelease, "6.0") >= 0 {
    kpackage { "isc-dhcp-server":; }

    service { "isc-dhcp-server":
      require    => Kpackage["isc-dhcp-server"],
      subscribe  => Kfile["/etc/dhcp/dhcpd.conf"],
      hasrestart => true,
      hasstatus  => true,
    }

    kfile { "/etc/dhcp/dhcpd.conf":
      require => Kpackage["isc-dhcp-server"],
      content => template("dhcp/dhcpd.conf");
    }
  }
}
