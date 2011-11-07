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
  kpackage { "btrfs-tools":
    ensure => latest,
  }
}
