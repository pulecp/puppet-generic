# Author: Kumina bv <support@kumina.nl>

# Class: cyrus::common
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class cyrus::common {
	package { ["cyrus-common-2.2", "cyrus-admin-2.2", "cyrus-clients-2.2"]:
		ensure => installed,
	}

	service { "cyrus2.2":
		enable => true,
		pattern => "/usr/sbin/cyrmaster",
		require => Package["cyrus-common-2.2"],
	}

	file { "/etc/cyrus.conf":
		source => "puppet://puppet/cyrus/cyrus.conf",
		owner => "root",
		group => "root",
		mode => 644,
		require => Package["cyrus-common-2.2"],
		notify => Service["cyrus2.2"];
	}

	# For some reason, this file is in the package cyrus-common, not
	# cyrus-imapd.
	file { "/etc/imapd.conf":
		source => "puppet://puppet/cyrus/imapd.conf",
		owner => "root",
		group => "root",
		mode => 644,
		require => Package["cyrus-common-2.2"],
		notify => Service["cyrus2.2"];
	}
}

# Class: cyrus::imap
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class cyrus::imap {
	package { "cyrus-imapd-2.2":
		ensure => installed,
	}
}
