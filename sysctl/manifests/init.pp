# Author: Kumina bv <support@kumina.nl>

# Class: sysctl
#
# Actions:
#  Setup sysctl exec.
#
# Depends:
#
class sysctl {
  exec { "reload-sysctl":
    command     => "/sbin/sysctl -p /etc/sysctl.conf",
    refreshonly => true;
  }
}

# Define: sysctl::setting
#
# Actions:
#  Setup a sysctl parameter
#
# Parameters:
#  name:  A general name or the parameter you'd like to set.
#  param: The parameter you'd like to set. Defaults to $name
#  value: The value you'd like to set the $param to with sysctl.
#
# Depends:
#  sysctl
#
define sysctl::setting ($value) {
  include sysctl

  kaugeas { "sysctl ${name}":
    file => '/etc/sysctl.conf',
    lens => 'Sysctl.lns',
    changes => "set ${name} '${value}'",
    notify  => Exec["reload-sysctl"];
  }
}
