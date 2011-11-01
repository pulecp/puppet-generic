# Author: Kumina bv <support@kumina.nl>

# Class: gen_logrotate
#
# Actions:
#  Set up logrotate
#
# Depends:
#  gen_puppet
#
class gen_logrotate {
  kpackage { "logrotate":
    ensure => latest,
  }

  kfile { "/etc/logrotate.d/":
    ensure => directory,
  }
}

# Class: gen_logrotate
#
# Actions:
#  Set up a logrotation
#
# Parameters
#  name
#    The name of the logrotate config file to create
#  logs
#    Defines which log file(s) to rotate
#  options
#    An array with the logrotate options, defaults to ["weekly","compress","rotate 7","missingok"]
#  prerotate
#    Defines a command to run before rotating the log
#  postrotate
#    Defines a command to run after rotating the log
#
# Depends:
#  gen_logrotate
#  gen_puppet
#
define gen_logrotate::rotate ($logs, $options=["weekly","compress","rotate 7","missingok"], $prerotate=false, $postrotate=false) {
  include gen_logrotate

  kfile { "/etc/logrotate.d/${name}":
    content => template("gen_logrotate/logrotate.erb");
  }
}
