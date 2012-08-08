# Author: Kumina bv <support@kumina.nl>

# Class: gen_timezone
#
# Actions:
#  Set the system's timezone
#
# Parameters:
#  tz
#    The timezone (defaults to Europe/Amsterdam)
#
# Depends:
#  gen_puppet
#
class gen_timezone ($tz="Europe/Amsterdam") {
  package { "tzdata":
    ensure    => "latest";
  }

  file { "/etc/localtime":
    ensure  => link,
    target  => "/usr/share/zoneinfo/${tz}";
  }
}

class gen_timezone::Amsterdam {
  class { "gen_timezone":
    tz => "Europe/Amsterdam";
  }
}

class gen_timezone::London {
  class { "gen_timezone":
    tz => "Europe/London";
  }
}
