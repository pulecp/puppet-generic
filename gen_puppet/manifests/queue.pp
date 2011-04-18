class gen_puppet::queue {
	# Install the stomp gem
	kpackage { "libstomp-ruby":
		ensure => latest,
	}
}
