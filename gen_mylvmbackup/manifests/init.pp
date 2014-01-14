# Author: Kumina bv <support@kumina.nl>

# Class: gen_mylvmbackup
#
# Actions:
#  Install mylvmbackup
#
class gen_mylvmbackup {
  package { "mylvmbackup":
    ensure => latest,
  }
}
