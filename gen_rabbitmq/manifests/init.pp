# Author: Kumina bv <support@kumina.nl>

# Class: gen_rabbitmq
#
# Actions:
#  Set up rabbitmq
#
# Depends:
#  gen_puppet
#
class gen_rabbitmq($ssl_cert = false, $ssl_key = false, $ssl_port = 5671, $disk_free_limit = 500000000) {
  kservice { "rabbitmq-server":
    srequire => Concat["/etc/rabbitmq/rabbitmq.config"],
  }

  gen_apt::source { "rabbitmq":
    uri          => "http://www.rabbitmq.com/debian",
    distribution => "testing",
    components   => ["main"];
  }

  if $ssl_cert {
    file {
      "/etc/rabbitmq/rabbitmq.key":
        content => $ssl_key,
        require => Package['rabbitmq-server'],
        notify  => Service["rabbitmq-server"];
      "/etc/rabbitmq/rabbitmq.pem":
        content => $ssl_cert,
        require => Package['rabbitmq-server'],
        notify  => Service["rabbitmq-server"];
    }

    concat::add_content { "/etc/rabbitmq/rabbitmq.config":
      content => template("gen_rabbitmq/rabbitmq.config"),
      target  => "/etc/rabbitmq/rabbitmq.config";
    }
  }

  gen_rabbitmq::delete_user { "guest":; }

  concat { "/etc/rabbitmq/rabbitmq.config":
    require => Package["rabbitmq"],
    notify  => Service["rabbitmq"];
  }
}

# Class: gen_rabbitmq::amqp
#
# Actions:
#  Set up rabbitmq with amqp
#
# Depends:
#  gen_puppet
#
class gen_rabbitmq::amqp($ssl_cert = false, $ssl_key = false, $ssl_port = 5671) {
  class { "gen_rabbitmq":
    ssl_cert => false,
    ssl_key  => false,
    ssl_port => 5671;
  }
}

# Class: gen_rabbitmq::stomp
#
# Actions:
#  Set up raasbitmq with stomp
#
# Depends:
#  gen_puppet
#
class gen_rabbitmq::stomp($ssl_cert = false, $ssl_key = false, $ssl_port = 5671) {
  class { "gen_rabbitmq::amqp":
    ssl_cert => false,
    ssl_key  => false,
    ssl_port => 5671;
  }

  concat::add_content { "rabbitmq config for stomp plugin":
      content => '[ {rabbitmq_stomp, [{tcp_listeners, [6163]} ]} ].',
      target  => "/etc/rabbitmq/rabbitmq.config";
  }

  line { "rabbitmq config for enabling stomp plugin":
    file    => "/etc/rabbitmq/enabled_plugins",
    content => '[rabbitmq_stomp].',
    require => Package["rabbitmq-server"],
    notify  => Service["rabbitmq-server"];
  }
}

define gen_rabbitmq::add_user($password) {
  exec { "add user ${name}":
    command => "/usr/sbin/rabbitmqctl add_user ${name} ${password}",
    unless  => "/usr/sbin/rabbitmqctl list_users | /bin/grep -qP \"^${name}\"",
    require => Service["rabbitmq-server"];
  }
}

define gen_rabbitmq::delete_user {
  exec { "delete user ${name}":
    command => "/usr/sbin/rabbitmqctl delete_user ${name}",
    onlyif  => "/usr/sbin/rabbitmqctl list_users | /bin/grep -qP \"^${name}\\t\"",
    require => Service["rabbitmq-server"];
  }
}

define gen_rabbitmq::set_permissions($vhostpath="/", $username, $conf='".*"', $write='".*"', $read='".*"') {
  if defined(Gen_rabbitmq::Vhost[$vhostpath]) {
    $req = [Gen_rabbitmq::Add_user[$username], Gen_rabbitmq::Vhost[$vhostpath]]
  } else {
    $req = Gen_rabbitmq::Add_user[$username]
  }

  exec { "set permission ${vhostpath} ${username}":
    command => "/usr/sbin/rabbitmqctl set_permissions -p ${vhostpath} ${username} ${conf} ${write} ${read}",
    unless  => "/usr/sbin/rabbitmqctl list_user_permissions -p ${vhostpath} ${username} | grep -qP \"${vhostpath}\\t${conf}\\t${write}\\t${read}\"",
    require => $req;
  }
}

define gen_rabbitmq::vhost ($ensure='present') {
  case $ensure {
    'present': {
      exec { "rabbitmq vhost $name":
        command => "/usr/sbin/rabbitmqctl add_vhost $name",
        unless  => "/usr/sbin/rabbitmqctl list_vhosts | grep -q '^$name\$'",
        require => Service['rabbitmq-server'];
      }
    }
    'absent': {
      exec { "rabbitmq vhost $name":
        command => "/usr/sbin/rabbitmqctl delete_vhost $name",
        onlyif  => "/usr/sbin/rabbitmqctl list_vhosts | grep -q '^$name\$'",
        require => Service['rabbitmq-server'];
      }
    }
  }
}
