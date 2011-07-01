# Author: Kumina bv <support@kumina.nl>

# Define: kservice
#
# Parameters:
#	hasrestart
#		Undocumented
#	hasstatus
#		Undocumented
#	ensure
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kservice ($ensure="running", $hasrestart=true, $hasstatus=true) {
	service { "${name}":
		ensure     => $ensure,
		hasrestart => $hasrestart,
		hasstatus  => $hasstatus;
	}

	if $lsbmajdistrelease < 6 {
		exec { "reload-${name}":
			command     => "/etc/init.d/${name} reload",
			refreshonly => true;
		}
	} else {
		exec { "reload-${name}":
			command     => "/usr/sbin/service ${name} reload",
			refreshonly => true;
		}
	}
}
