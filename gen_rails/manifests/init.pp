class gen_rails {
	# Install the packages
	kpackage { ["rails", "libmysql-ruby"]:
		ensure => latest,
	}
}
