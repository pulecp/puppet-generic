# Author: Kumina bv <support@kumina.nl>

# Class: pysieved
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class pysieved {
  package { "pysieved":
    ensure => installed,
  }

  exec { "/usr/sbin/update-inetd --enable sieve":
    unless => "/bin/grep -q ^sieve /etc/inetd.conf",
    require => Package["pysieved"],
  }
}
