# Author: Kumina bv <support@kumina.nl>

# Class: gen_base::wget
#
# Actions:
#	Set up wget
#
# Depends:
#	gen_puppet
#
class gen_base::wget {
	kpackage { "wget":
		ensure => latest;
	}
}

# Class: gen_base::libnet-dns-perl
#
# Actions:
#	Set up libnet-dns-perl
#
# Depends:
#	gen_puppet
#
class gen_base::libnet-dns-perl {
	kpackage { "libnet-dns-perl":; }
}
