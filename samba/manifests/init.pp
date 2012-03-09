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
  kpackage { "samba-common":; }
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

  kpackage { "samba":
    require => Package["samba-common"];
  }

  service { "samba":
    subscribe => File["/etc/samba/smb.conf"],
    pattern => "smbd",
  }

  file { "/etc/samba/smb.conf":
    content => template("samba/samba/smb.conf"),
    require => Package["samba"];
  }
}
