# Author: Kumina bv <support@kumina.nl>

# Class: gen_base::ant
#
# Actions:
#	Install ant
#
# Depends:
#	gen_puppet
#
class gen_base::ant {
	kpackage { "ant":
		ensure => latest;
	}
}

# Class: gen_base::libaugeas-ruby
#
# Actions:
#	Install augeas and it's lenses
#
# Depends:
#	gen_puppet
#
class gen_base::augeas {
	kpackage { ["libaugeas-ruby", "augeas-lenses","libaugeas-ruby1.8","libaugeas0"]:
		ensure => latest;
	}
}

# Class: gen_base::base-files
#
# Actions:
#	Install base-files
#
# Depends:
#	gen_puppet
#
class gen_base::base-files {
	kpackage { "base-files":
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

# Class: gen_base::facter
#
# Actions:
#	Install facter
#
# Depends:
#	gen_puppet
#
class gen_base::facter {
	kpackage { "facter":
		ensure => latest,
		notify => Exec["reload-puppet"];
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

# Class: gen_base::libapache2-mod-passenger
#
# Actions:
#	Install libapache2-mod-passenger
#
# Depends:
#	gen_puppet
#
class gen_base::libapache2-mod-passenger {
	kpackage { "libapache2-mod-passenger":
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

# Class: gen_base::libapr1
#
# Actions:
#	Install libapr1
#
# Depends:
#	gen_puppet
#
class gen_base::libapr1 {
	kpackage { "libapr1":
		ensure => latest;
	}
}

# Class: gen_base::libcommons-logging-java
#
# Actions:
#	Install libcommons-logging-java
#
# Depends:
#	gen_puppet
#
class gen_base::libcommons-logging-java {
	kpackage { "libcommons-logging-java":
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

# Class: gen_base::liblog4j1.2-java
#
# Actions:
#	Install liblog4j1.2-java
#
# Depends:
#	gen_puppet
#
class gen_base::liblog4j1_2-java {
	kpackage { "liblog4j1.2-java":
		ensure => latest;
	}
}

# Class: gen_base::libreadline5-dev
#
# Actions:
#	Install libreadline5-dev
#
# Depends:
#	gen_puppet
#
class gen_base::libreadline5-dev {
	kpackage { "libreadline5-dev":
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

# Class: gen_base::libssl-dev
#
# Actions:
#	Install libssl-dev
#
# Depends:
#	gen_puppet
#
class gen_base::libssl-dev {
	kpackage { "libssl-dev":
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

# Class: gen_base::linux-base
#
# Actions:
#	Install linux-base
#
# Depends:
#	gen_puppet
#
class gen_base::linux-base {
	kpackage { "linux-base":
		ensure => latest;
	}
}

# Class: gen_base::linux-image
#
# Actions:
#	Make sure the latest image is installed
#
# Parameters:
#	version
#		The version we need to install the latest package of.
#
# Depends:
#	gen_puppet
#
class gen_base::linux-image ($version) {
	kpackage { "linux-image-${version}":
		ensure => latest;
	}

	# Also install the normal lenny kernel if we're not running the backports kernel already
	if ($lsbdistcodename == "lenny") and ($kernelrelease != "2.6.26-2-amd64") {
		kpackage { "linux-image-2.6.26-2-amd64":
			ensure => latest;
		}
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

# Class: gen_base::netpbm
#
# Actions:
#	Install netpbm
#
# Depends:
#	gen_puppet
#
class gen_base::netpbm {
	kpackage { "netpbm":
		ensure => installed;
	}
}

# Class: gen_base::openssl
#
# Actions:
#	Install openssl
#
# Depends:
#	gen_puppet
#
class gen_base::openssl {
	kpackage { "openssl":
		ensure => installed;
	}
}

# Class: gen_base::openjdk-6-jre
#
# Actions:
#	Install openjdk-6-jre
#
# Depends:
#	gen_puppet
#
class gen_base::openjdk-6-jre {
	kpackage { "openjdk-6-jre":
		ensure => installed;
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

# Class: gen_base::python-argparse
#
# Actions:
#	Install python-argparse
#
# Depends:
#	gen_puppet
#
class gen_base::python-argparse {
	kpackage { "python-argparse":
		ensure => latest;
	}
}

# Class: gen_base::python-dnspython
#
# Actions:
#	Install python-dnspython
#
# Depends:
#	gen_puppet
#
class gen_base::python-dnspython {
	kpackage { "python-dnspython":
		ensure => latest;
	}
}

# Class: gen_base::python-ipaddr
#
# Actions:
#	Install python-ipaddr
#
# Depends:
#	gen_puppet
#
class gen_base::python-ipaddr {
	kpackage { "python-ipaddr":
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

# Class: gen_base::ruby_stomp
#
# Actions:
#	Install ruby-stomp 1.1.9 from the Kumina repository
#
# Depends:
#	gen_puppet
#
class gen_base::ruby_stomp {
	kpackage { "ruby-stomp":
		ensure => latest;
	}
}

# Class: gen_base::simple-cdd
#
# Actions:
#	Install simple-cdd
#
# Depends:
#	gen_puppet
#
class gen_base::simple-cdd {
	kpackage { "simple-cdd":
		ensure => latest;
	}
}

# Class: gen_base::unzip
#
# Actions:
#	Install unzip
#
# Depends:
#	gen_puppet
#
class gen_base::unzip {
	kpackage { "unzip":
		ensure => latest;
	}
}

# Class: gen_base::vim
#
# Actions:
#	Install vim
#
# Depends:
#	gen_puppet
#
class gen_base::vim {
	kpackage { "vim":
		ensure => latest;
	}
}

# Class: gen_base::vim-addon-manager
#
# Actions:
#	Install vim-addon-manager
#
# Depends:
#	gen_puppet
#
class gen_base::vim-addon-manager {
	kpackage { "vim-addon-manager":
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

# Class: gen_base::xvfb
#
# Actions:
#	Install xvfb
#
# Depends:
#	gen_puppet
#
class gen_base::xvfb {
	kpackage { "xvfb":
		ensure => latest;
	}
}
