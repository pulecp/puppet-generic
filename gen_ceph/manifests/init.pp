# Author: Kumina bv <support@kumina.nl>

# Class: gen_ceph
#
# Actions:
#  Install the ceph package. Which makes this currently an unusable class,
#  since you need extra sources for even finding the package.
#
# Depends:
#  gen_puppet
#
class gen_ceph {
  kpackage { "ceph":
    ensure => latest,
  }
}
