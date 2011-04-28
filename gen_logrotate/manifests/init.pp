class gen_logrotate {
	kpackage { "logrotate":; }

	define rotate ($log, $options = [ "weekly", "compress", "rotate 7", "missingok" ], $prerotate = "NONE", $postrotate = "NONE") {
		kfile { "/etc/logrotate.d/${name}":
			mode    => 644,
			content => template("gen_logrotate/logrotate.erb");
		}
	}

	kfile { "/etc/logrotate.d/":
		ensure => directory,
	}

}
