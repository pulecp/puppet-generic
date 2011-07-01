# Author: Kumina bv <support@kumina.nl>

# Class: openntpd::common
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class openntpd::common {
	package { "openntpd":
		ensure => installed,
	}

	service { "openntpd":
		hasrestart => true,
		ensure => running,
		pattern => "/usr/sbin/ntpd",
		require => Package["openntpd"],
	}
}
