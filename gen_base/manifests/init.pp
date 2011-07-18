# Author: Kumina bv <support@kumina.nl>

# Class: gen_base::libactiverecord_ruby18
#
# Actions:
#	Install libactiverecord-ruby1.8
#
# Depends:
#	gen_puppet
#
class gen_base::libactiverecord_ruby18 {
	kpackage { "libactiverecord-ruby1.8":
		ensure => latest;
	}
}

# Class: gen_base::libnet_dns_perl
#
# Actions:
#	Install libnet-dns-perl
#
# Depends:
#	gen_puppet
#
class gen_base::libnet_dns_perl {
	kpackage { "libnet-dns-perl":
		ensure => latest;
	}
}

# Class: gen_base::libstomp_ruby
#
# Actions:
#	Install libstomp-ruby
#
# Depends:
#	gen_puppet
#
class gen_base::libstomp_ruby {
	kpackage { "libstomp-ruby":
		ensure => latest;
	}
}

# Class: gen_base::curl
#
# Actions:
#	Install curl
#
# Depends:
#	gen_puppet
#
class gen_base::curl {
	kpackage { "curl":
		ensure => latest;
	}
}

# Class: gen_base::dnsutils
#
# Actions:
#	Install dnsutils
#
# Depends:
#	gen_puppet
#
class gen_base::dnsutils {
	kpackage { "dnsutils":
		ensure => latest;
	}
}

# Class: gen_base::jmxquery
#
# Actions:
#	Install jmxquery
#
# Depends:
#	gen_puppet
#
class gen_base::jmxquery {
	kpackage { "jmxquery":
		ensure => latest;
	}
}

# Class: gen_base::nagios-nrpe-plugin
#
# Actions:
#	Install nagios-nrpe-plugin
#
# Depends:
#	gen_puppet
#
class gen_base::nagios-nrpe-plugin {
	kpackage { "nagios-nrpe-plugin":
		ensure => latest;
	}
}

# Class: gen_base::nagios-plugins-standard
#
# Actions:
#	Install nagios-plugins-standard
#
# Depends:
#	gen_puppet
#
class gen_base::nagios-plugins-standard {
	kpackage { "nagios-plugins-standard":
		ensure => latest;
	}
}

# Class: gen_base::wget
#
# Actions:
#	Install wget
#
# Depends:
#	gen_puppet
#
class gen_base::wget {
	kpackage { "wget":
		ensure => latest;
	}
}
