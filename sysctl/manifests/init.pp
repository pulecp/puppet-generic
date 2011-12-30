# Author: Kumina bv <support@kumina.nl>

# Class: sysctl
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class sysctl {
  exec { "/sbin/sysctl -p /etc/sysctl.conf":
    subscribe   => File["/etc/sysctl.conf"],
    refreshonly => true;
  }
  # XXX: Above construct seems broken?
  #      Why?
  #exec { "/sbin/sysctl -p /etc/sysctl.conf":; }

  file { "/etc/sysctl.conf":
    checksum => "md5",
  }
}
