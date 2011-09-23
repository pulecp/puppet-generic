# Author: Kumina bv <support@kumina.nl>

# Class: gen_s3fs
#
# Actions:
#	Set up s3fs
#
# Depends:
#	gen_puppet
#
class gen_s3fs {
	kpackage { "s3fs":
		ensure => latest,
	}
}
