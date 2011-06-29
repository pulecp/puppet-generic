define kservice ($ensure="running", $hasrestart=true, $hasstatus=true) {
	service { "${name}":
		ensure     => $ensure,
		hasrestart => $hasrestart,
		hasstatus  => $hasstatus;
	}
}
