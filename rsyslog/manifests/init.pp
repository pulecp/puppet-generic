class rsyslog::common {
	package { "rsyslog":
		ensure => installed,
	}

	service { "rsyslog":
		enable => true,
		require => Package["rsyslog"],
	}
}

class rsyslog::client {
	include rsyslog::common

	kfile { "/etc/rsyslog.d/remote-logging-client.conf":
		content => template("rsyslog/client/remote-logging-client.conf"),
		require => Package["rsyslog"],
		notify => Service["rsyslog"],
	}
}

class rsyslog::server {
	include rsyslog::common

	kfile { "/etc/rsyslog.d/remote-logging-server.conf":
		source => "rsyslog/server/remote-logging-server.conf",
		require => Package["rsyslog"],
		notify => Service["rsyslog"],
	}
}

class rsyslog::mysql {
	package { "rsyslog-mysql":
		ensure => installed,
	}
}
