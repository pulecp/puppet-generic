# Author: Kumina bv <support@kumina.nl>

# Class: asterisk::server
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class asterisk::server {
  package {
    "asterisk-sounds-extra":
      ensure => present;
  }

  kservice {
    "asterisk":
      ensure => running;
  }

}

# Class: asterisk::zaptel-module-xen
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class asterisk::zaptel-module-xen {
  $archdependent = $architecture ? {
    i386  => "zaptel-modules-2.6.26-2-xen-686",
    amd64 => "zaptel-modules-2.6.26-2-xen-amd64",
  }

  # Architecture dependent packages.
  package {
    $archdependent:
      require => Package["asterisk"],
      ensure => present;
  }
}
