# Author: Kumina bv <support@kumina.nl>

# Class: gen_rabbitmq
#
# Actions:
#	Set up rabbitmq
#
# Depends:
#	gen_puppet
#
class gen_rabbitmq($version=false, $ssl_cert = false, $ssl_key = false, $ssl_port = 5671) {
	kservice { "rabbitmq-server":
		pensure => $version ? {
			false   => undef,
			default => $version,
		};
	}

	if $ssl_cert {
		kfile {
			"/etc/rabbitmq/rabbitmq.key":
				source => $ssl_key,
				notify  => Service["rabbitmq-server"];
			"/etc/rabbitmq/rabbitmq.pem":
				source => $ssl_cert,
				notify  => Service["rabbitmq-server"];
			"/etc/rabbitmq/rabbitmq.config":
				content => template("gen_rabbitmq/rabbitmq.config"),
				notify  => Service["rabbitmq-server"];
		}
	}
}

# Class: gen_rabbitmq::amqp
#
# Actions:
#	Set up rabbitmq with amqp
#
# Depends:
#	gen_puppet
#
class gen_rabbitmq::amqp($version) {
	class { "gen_rabbitmq":
		version => $version;
	}

	$shortversion=regsubst($version,'^(.*?)-(.*)$','\1')

	kfile { "/usr/lib/rabbitmq/lib/rabbitmq_server-$shortversion/plugins/amqp_client-$shortversion.ez":
		source  => "gen_rabbitmq/amqp_client-$shortversion.ez",
		require => Kpackage["rabbitmq-server"],
		notify  => Service["rabbitmq-server"],
	}
}

# Class: gen_rabbitmq::stomp
#
# Actions:
#	Set up raasbitmq with stomp
#
# Depends:
#	gen_puppet
#
class gen_rabbitmq::stomp($version) {
	class { "gen_rabbitmq::amqp":
		version => $version;
	}

	$shortversion=regsubst($version,'^(.*?)-(.*)$','\1')

	kfile { "/usr/lib/rabbitmq/lib/rabbitmq_server-$shortversion/plugins/stomp_client-$shortversion.ez":
		source  => "gen_rabbitmq/stomp_client-$shortversion.ez",
		require => Kpackage["rabbitmq-server"],
		notify  => Service["rabbitmq-server"],
	}

	line { "rabbitmq config for stomp plugin":
		file    => "/etc/rabbitmq/rabbitmq-env.conf",
		content => 'SERVER_START_ARGS="-rabbit_stomp listeners [{\"0.0.0.0\",6163}]"',
		notify  => Service["rabbitmq-server"],
		require => Kfile["/etc/rabbitmq/rabbitmq-env.conf"];
	}
}
