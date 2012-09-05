# Author: Kumina bv <support@kumina.nl>

# Class: gen_postgrey
#
# Actions:
#  Basic Postgrey installation
#
# Depends:
#  gen_puppet
#
class gen_postgrey {
  kservice { 'postgrey':; }
}
