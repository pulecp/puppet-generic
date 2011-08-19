# Author: Kumina bv <support@kumina.nl>

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

# Class: gen_base::echoping
#
# Actions:
#	Install echoping
#
# Depends:
#	gen_puppet
#
class gen_base::echoping {
	kpackage { "echoping":
		ensure => latest;
	}
}

# Class: gen_base::javascript-common
#
# Actions:
#	Install javascript-common
#
# Depends:
#	gen_puppet
#
class gen_base::javascript-common {
	kpackage { "javascript-common":
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

# Class: gen_base::libapache2-mod-php5
#
# Actions:
#	Install libapache2-mod-php5
#
# Depends:
#	gen_puppet
#
class gen_base::libapache2-mod-php5 {
	kpackage { "libapache2-mod-php5":
		ensure => latest;
	}
}

# Class: gen_base::libfreetype6
#
# Actions:
#	Install libfreetype6
#
# Depends:
#	gen_puppet
#
class gen_base::libfreetype6 {
	kpackage { "libfreetype6":
		ensure => latest;
		# Grub needs this package......
	}
}

# Class: gen_base::libio-socket-inet6-perl
#
# Actions:
#	Install libio-socket-inet6-perl
#
# Depends:
#	gen_puppet
#
class gen_base::libio-socket-inet6-perl {
	kpackage { "libio-socket-inet6-perl":
		ensure => latest;
	}
}

# Class: gen_base::libmozjs2d
#
# Actions:
#	Install libmozjs2d
#
# Depends:
#	gen_puppet
#
class gen_base::libmozjs2d {
	kpackage { "libmozjs2d":
		ensure => latest;
	}
}

# Class: gen_base::libmysql-ruby
#
# Actions:
#	Install libmysql-ruby
#
# Depends:
#	gen_puppet
#
class gen_base::libmysql-ruby {
	kpackage { "libmysql-ruby":
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

# Class: gen_base::libsocket6-perl
#
# Actions:
#	Install libsocket6-perl
#
# Depends:
#	gen_puppet
#
class gen_base::libsocket6-perl {
	kpackage { "libsocket6-perl":
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

# Class: gen_base::mc
#
# Actions:
#	Install mc
#
# Depends:
#	gen_puppet
#
class gen_base::mc {
	kpackage { "mc":
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

# Class: gen_base::php5-mysql
#
# Actions:
#	Install php5-mysql
#
# Depends:
#	gen_puppet
#
class gen_base::php5-mysql {
	kpackage { "php5-mysql":
		ensure => latest;
	}
}

# Class: gen_base::rails
#
# Actions:
#	Install rails
#
# Depends:
#	gen_puppet
#
class gen_base::rails {
	kpackage { "rails":
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
