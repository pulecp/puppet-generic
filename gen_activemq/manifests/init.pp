# Author: Kumina bv <support@kumina.nl>

# Class: gen_activemq
#
# Actions:
#	Sets up activemq
#
# Depends:
#	gen_puppet
#
class gen_activemq {
	kservice { "activemq":; }
}
