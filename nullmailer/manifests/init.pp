# Author: Kumina bv <support@kumina.nl>

# Class: nullmailer
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class nullmailer {
	kservice { "nullmailer":
		hasstatus => false,
		ensure    => running;
	}

	package {
		"postfix":
			ensure => absent;
		"exim4":
			ensure => absent;
		"exim4-daemon-light":
			ensure => absent;
		"exim4-base":
			ensure => absent;
		"exim4-config":
			ensure => absent;
	}

	file {
		"/etc/nullmailer/adminaddr":
			content => "${mail_catchall}\n",
			notify => Service["nullmailer"],
			require => Package["nullmailer"];
		"/etc/nullmailer/remotes":
			content => "${mail_relay}\n",
			notify => Service["nullmailer"],
			require => Package["nullmailer"];
		"/etc/mailname":
			content => "${fqdn}\n",
			notify => Service["nullmailer"],
			require => Package["nullmailer"];
	}
}
