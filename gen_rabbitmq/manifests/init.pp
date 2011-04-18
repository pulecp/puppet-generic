class gen_rabbitmq {
	# This requires the source to be added!
	kpackage { "rabbitmq-server":
		ensure => latest,
	}

	exec { "reload-rabbitmq":
		command     => "/etc/init.d/rabbitmq-server reload",
		refreshonly => true,
	}
}

class gen_rabbitmq::plugin::amqp {
	include gen_rabbitmq

	# This probably should be a package as well, but let's solve it with a sourced
	# file for now.
	kfile { "/usr/lib/rabbitmq/lib/rabbitmq_server-2.4.1/plugins/amqp_client-2.4.1.ez":
		source  => "gen_rabbitmq/plugins/amqp_client-2.4.1.ez",
		require => Kpackage["rabbitmq-server"],
		notify  => Exec["reload-rabbitmq"],
	}
}

class gen_rabbitmq::plugin::stomp {
	# Stomp plugin requires amqp
	include gen_rabbitmq::plugin::amqp

	# This probably should be a package as well, but let's solve it with a sourced
	# file for now.
	kfile { "/usr/lib/rabbitmq/lib/rabbitmq_server-2.4.1/plugins/stomp_client-2.4.1.ez":
		source  => "gen_rabbitmq/plugins/stomp_client-2.4.1.ez",
		require => Kpackage["rabbitmq-server"],
		notify  => Exec["reload-rabbitmq"],
	}
}

