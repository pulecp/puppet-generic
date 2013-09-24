#
# Class: gen_logstash
#
# Actions: Install and set up logstash
#
# Parameters:
#  config: A big-ass string containing the full content of the desired logstash config file
#
# Depends:
#  gen_puppet
#
class gen_logstash ($config) {
  kservice { 'logstash':
    srequire => File['/etc/default/logstash','/etc/logstash/conf.d/logstash.conf'];
  }

  file {
    '/etc/default/logstash':
      content => template('gen_logstash/default'),
      require => Package['logstash'];
    # this is where we drop regex patterns for grok
    '/etc/logstash/patterns':
      ensure  => directory,
      recurse => true,
      source  => 'puppet:///modules/gen_logstash/patterns',
      require => Package['logstash'];
    '/etc/logstash/conf.d/logstash.conf':
      content => $config,
      require => Package['logstash'],
      notify  => Exec['restart-logstash'];
  }
}

#
# Class: gen_logstash::lumberjack
#
# Actions: Install and set up lumberjack
#
# Parameters:
#  servers: An array containing the logstash-server addresses
#  sslca: The name of the SSL CA certificate (in /etc/ssl/certs) without .pem extension
#
# Depends:
#  gen_puppet
#
class gen_logstash::lumberjack ($servers, $sslca) {
  kservice { 'lumberjack':
    srequire => Concat['/etc/lumberjack.conf'];
  }

  concat { '/etc/lumberjack.conf':
    require => Package['lumberjack'],
    notify  => Exec['restart-lumberjack'];
  }

  concat::add_content {
    'lumberjack head':
      order   => 100,
      content => template('gen_logstash/lumberjack_head'),
      target  => '/etc/lumberjack.conf';
    'lumberjack tail':
      order   => 200,
      content => template('gen_logstash/lumberjack_tail'),
      target  => '/etc/lumberjack.conf';
  }
}

#
# Define: gen_logstash::lumberjack::files
#
# Actions: Add a files section to the lumberjack config
#
# Parameters:
#  type: The type of file, this is used in logstash to determine which filters should be applied
#  files: An array of paths to files of this type (globbing is supported
#         in lumberjack, so "/var/log/some_app/*.log" is supported). $name is used in absence of this parameter
#
# Depends:
#  gen_logstash::lumberjack
#  gen_puppet
#
define gen_logstash::lumberjack::files ($file_type, $files=false) {
  $the_files = $files ? {
    false   => $name,
    default => $files,
  }
  concat::add_content { "lumberjack files ${name}":
    order   => 150,
    content => template('gen_logstash/lumberjack_file'),
    target  => '/etc/lumberjack.conf';
  }
}
