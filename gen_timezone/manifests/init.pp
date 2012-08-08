# Author: Kumina bv <support@kumina.nl>

# Define: gen_timezone::tz
#
# Actions:
#  Set the system's timezone
#  This is a defined type because it's impossible to change a
#  class' parameters later
#
# Parameters:
#  tz
#    The timezone (defaults to Europe/Amsterdam)
#
# Depends:
#  gen_puppet
#
define gen_timezone::tz ($tz) {
  package { "tzdata":
    ensure => "latest";
  }

  file {
    "/etc/timezone":
      ensure  => present,
      content => "${tz}\n";
    "/etc/localtime":
      ensure  => link,
      target  => "/usr/share/zoneinfo/${tz}",
      require => Package["tzdata"];
  }
}

# Class: gen_timezone
#
# Actions:
#  Set the default timezone (Europe/Amsterdam)
#
# Parameters:
#
# Depends:
#  gen_timezone
#
class gen_timezone {
  gen_timezone::tz { "timezone":
    tz => "Europe/Amsterdam";
  }
}
