# Author: Kumina bv <support@kumina.nl>

# Class: gen_amavisd-new
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_amavisd-new {
	kpackage { "amavisd-new":; }

	kservice { "amavis":
		require => Kpackage["amavisd-new"];
	}
}
