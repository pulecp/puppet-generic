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
			command     => "service ${name} reload",
			refreshonly => true;
		}
	}
}
