# Author: Kumina bv <support@kumina.nl>

# Class: ntp
#
# Actions:
#   Undocumented
#
# Depends:
#   Undocumented
#   gen_puppet
#
class ntp {
  package { "ntp":
    ensure => latest;
  }

  service { "ntp":
    hasrestart => true,
    hasstatus  => true,
    ensure     => running,
    require    => Package["ntp"];
  }

  # if the variable $ntpservers exists it will use those
  # if not, the defaults from pool.ntp.org are used
  $real_ntpservers = $ntpservers ? {
    undef   => false,
    default => $ntpservers,
  }

  file { "/etc/ntp.conf":
    content => template("ntp/ntp.conf"),
    require => Package["ntp"],
    notify  => Service["ntp"];
  }
}
