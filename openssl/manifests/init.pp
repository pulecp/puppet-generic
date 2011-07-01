# Author: Kumina bv <support@kumina.nl>

# Class: openssl::common
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class openssl::common {
	package { "openssl":
		ensure => installed,
	}

	file {
		"/etc/ssl/certs":
			require => Package["openssl"],
			checksum => "md5",
			recurse => true;
	}
}

# Class: openssl::server
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class openssl::server {
	include openssl::common

}

# Class: openssl::ca
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class openssl::ca {
	include openssl::common

	file {
		"/etc/ssl/newcerts":
			ensure => directory,
			mode => 750,
			owner => "root",
			group => "root",
			require => Package["openssl"];
		"/etc/ssl/requests":
			ensure => directory,
			mode => 750,
			owner => "root",
			group => "root",
			require => Package["openssl"];
		"/etc/ssl/Makefile":
			source => "puppet:///modules/openssl/Makefile",
			mode => 644,
			owner => "root",
			group => "root",
			require => Package["openssl"];
	}
}
