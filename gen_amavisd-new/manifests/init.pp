# Author: Kumina bv <support@kumina.nl>

# Class: gen_amavisd-new
#
# Actions:
#	Sets up amavis
#
# Depends:
#	gen_puppet
#
class gen_amavisd-new {
	kservice { "amavis":
		package => "amavisd-new";
	}
}
