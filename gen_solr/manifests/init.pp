# Author: Kumina bv <support@kumina.nl>

# Class: gen_solr
#
# Actions:
#  Basic setup of solr
#
# Depends:
#  gen_puppet
#
class gen_solr {
  kpackage { "solr-common":; }
}
