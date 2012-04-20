# Author: Kumina bv <support@kumina.nl>

# Class: samba::common
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class samba::common {
  package { "samba-common":; }
}

# Class: samba::server
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class samba::server {
  include samba::common

  package { "samba":
    require => Package["samba-common"];
  }

  service { "samba":
    subscribe => File["/etc/samba/smb.conf"],
    pattern => "smbd",
  }

  file { "/etc/samba/smb.conf":
    content => template("samba/smb.conf"),
    require => Package["samba"];
  }
}
