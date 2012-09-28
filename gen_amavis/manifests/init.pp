# Author: Kumina bv <support@kumina.nl>

# Class: gen_amavis
#
# Actions:
#  Basic Amavis installation
#
# Depends:
#  gen_puppet
#  gen_base
#
class gen_amavis {
  include gen_base::zoo
  include gen_base::arj
  include gen_base::cabextract

  kservice { 'amavis':
    package   => 'amavisd-new',
    hasreload => false,
    require   => Package['zoo', 'arj', 'cabextract'];
  }
}
