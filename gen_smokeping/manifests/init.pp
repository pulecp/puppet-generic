# Author: Kumina bv <support@kumina.nl>

# Class: gen_smokeping::server
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_smokeping::server {

	kpackage { ["smokeping","javascript-common", "libsocket6-perl", "libio-socket-inet6-perl", "echoping"]:; }
	service { "smokeping":
		ensure => running,
		hasrestart => true,
		require => Kpackage["smokeping"];
	}

	define config ($content=false, $source=false) {
		if $content!=false and $source!=false {
			fail("cant define source AND file")
		}
		if $content==false and $source==false {
			fail("must define source OR file")
		}

		if $content {
			kfile { "/etc/smokeping/config.d/${name}":
				content => $content,
				notify  => Service["smokeping"];
			}
		
		} elsif $source {
			kfile { "/etc/smokeping/config.d/${name}":
				source => $source,
				notify => Service["smokeping"];
			}
		}
	}
}
