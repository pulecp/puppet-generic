# Author: Kumina bv <support@kumina.nl>

# Define: kservice
#
# Parameters:
#  hasreload
#    Defines if the service has a reload option, can be set to the command to use for reloads
#  hasrestart
#    Defines if the service has a restart option, can be set to the command to use for restarts
#  hasstatus
#    Defines if the service has a status option
#  ensure
#    Defines whether the service should be running or not
#  enable
#    Defines whether the service should be started at boot, defaults to true
#  package
#    If defined sets the package to install
#  pensure
#    The ensure for the package
#  srequire
#    If the service start depends on something else, use this to set the require for service.
#
# Actions:
#  Install a package, starts the service and creates a reload exec.
#
# Depends:
#  gen_puppet
#
define kservice ($ensure="running", $hasreload=true, $hasrestart=true, $hasstatus=true, $enable=true, $package=$name, $pensure="present", $pattern=false, $srequire=false) {
  package { $package:
    ensure => $pensure;
  }

  service { $name:
    ensure     => $ensure ? {
      "undef" => undef,
      default => $ensure,
    },
    hasrestart => $hasrestart ? {
      true    => true,
      default => false,
    },
    hasstatus  => $pattern ? {
      false   => $hasstatus,
      default => false,
    },
    enable     => $enable,
    pattern    => $pattern ? {
      false   => undef,
      default => $pattern,
    },
    require    => $srequire ? {
      false   => Package[$package],
      default => [Package[$package],$srequire],
    };
  }

  if $hasreload {
    if $lsbdistcodename == 'lenny' {
      exec { "reload-${name}":
        command     => $hasreload ? {
          true    => "/etc/init.d/${name} reload",
          default => $hasreload,
        },
        refreshonly => true,
        require     => Package[$package];
      }
    } else {
      exec { "reload-${name}":
        command     => $hasreload ? {
          true    => "/usr/sbin/service ${name} reload",
          default => $hasreload,
        },
        refreshonly => true,
        require     => Package[$package];
      }
    }
  } else {
    exec { "reload-${name}":
      command     => "/bin/true",
      notify      => Service[$name],
      refreshonly => true,
      require     => Package[$package];
    }
  }

  if $hasrestart {
    if $lsbdistcodename == 'lenny' {
      exec { "restart-${name}":
        command     => $hasrestart ? {
          true    => "/etc/init.d/${name} restart",
          default => $hasrestart,
        },
        refreshonly => true,
        require     => Package[$package];
      }
    } else {
      exec { "restart-${name}":
        command     => $hasrestart ? {
          true    => "/usr/sbin/service ${name} restart",
          default => $hasrestart,
        },
        refreshonly => true,
        require     => Package[$package];
      }
    }
  } else {
    exec { "restart-${name}":
      command     => "/bin/true",
      notify      => Service[$name],
      refreshonly => true,
      require     => Package[$package];
    }
  }
}
