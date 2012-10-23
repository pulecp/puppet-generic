# Author: Kumina bv <support@kumina.nl>

# Class: gen_kvm
#
# Actions:
#  Set up qemu-kvm
#
# Depends:
#  gen_puppet
#
class gen_kvm {

  # Against our policy we use a define from an other gen class here, but we'd have to do other icky stuff if we didn't
  if $lsbdistcodename == 'lenny' or $lsbdistcodename == 'squeeze' {
    gen_apt::preference { "qemu-kvm":; }
  }

  # In squeeze, pin both.
  if $lsbdistcodename == 'squeeze' {
    include gen_base::libspice_server1
    gen_apt::preference { ["kvm","libspice-server1","seabios","vgabios","libpixman-1-0"]:; }
  }

  package { "qemu-kvm":
    ensure => latest,
  }
}
