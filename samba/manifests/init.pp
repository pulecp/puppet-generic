class samba::common {
	kpackage { "samba-common":; }
}

class samba::server {
	include samba::common

	kpackage { "samba":
		require => Package["samba-common"];
	}

	service { "samba":
		subscribe => File["/etc/samba/smb.conf"],
		pattern => "smbd",
	}

	kfile { "/etc/samba/smb.conf":
		source => "samba/samba/smb.conf",
		require => Package["samba"];
	}
}
