# Author: Kumina bv <support@kumina.nl>

# Class: gen_btrfs
#
# Actions:
#  Install the btrfs tools.
#
# Depends:
#  gen_puppet
#
class gen_btrfs {
  package { "btrfs-tools":
    ensure => latest,
  }
}
