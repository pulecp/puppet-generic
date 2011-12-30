# Author: Kumina bv <support@kumina.nl>

# Define: kpackage
#
# Parameters:
#	responsefile
#		Undocumented
#	ensure
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kpackage ($ensure="present", $responsefile=false) {
  package { "${name}":
    ensure       => $ensure,
    responsefile => $responsefile ? {
      false   => undef,
      default => $responsefile,
    },
    require      => Exec["/usr/bin/apt-get update"];
  }
}
