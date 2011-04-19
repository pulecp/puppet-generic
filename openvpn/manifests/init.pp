class openvpn::common {
	kpackage { "openvpn":; }
}

class openvpn::server {
	include openvpn::common

	kfile {
		"/etc/openvpn/server.conf":
			source => "openvpn/server.conf",
			require => [Package["openvpn"], File["/var/lib/openvpn"]];
		"/var/lib/openvpn":
			ensure => "directory",
			mode => 750;
	}

	service { "openvpn":
		subscribe => File["/etc/openvpn/server.conf"],
		ensure    => running;
	}

}

class openvpn::client {
	include openvpn::common

	kfile { "/etc/openvpn/client.conf":
		source => "openvpn/client.conf",
		require => Package["openvpn"],
	}
}
