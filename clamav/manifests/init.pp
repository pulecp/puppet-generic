# Author: Kumina bv <support@kumina.nl>

# Class: clamav
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class clamav {
  package { ["clamav-daemon", "clamav-freshclam", "clamav-base", "libclamav6"]:
    ensure => latest,
  }

  service { "clamav-daemon":
    enable => true,
    pattern => "/usr/sbin/clamd",
    require => Package["clamav-daemon"],
  }

  service { "clamav-freshclam":
    enable => true,
    pattern => "/usr/bin/freshclam",
    require => Package["clamav-freshclam"],
  }
}
