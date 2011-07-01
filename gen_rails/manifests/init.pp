# Author: Kumina bv <support@kumina.nl>

# Class: gen_rails
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_rails {
	# Install the packages
	kpackage { ["rails", "libmysql-ruby"]:
		ensure => latest,
	}
}
