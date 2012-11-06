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
define sysctl::setting ($param = $name, $value) {
  include sysctl

  exec { "Set ${param} to ${value} for Sysctl::Setting '${name}'":
    command => "/bin/echo '${param} = ${value}' >> '/etc/sysctl.conf'",
    unless  => "/bin/grep -Fx '${param} = ${value}' /etc/sysctl.conf",
    notify  => Exec["reload-sysctl"];
  }
}
