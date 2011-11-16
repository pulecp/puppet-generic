# Author: Kumina bv <support@kumina.nl>

# Define: kaugeas
#
# Parameters:
#  file
#    The file to apply the change to (akin to incl in augeas)
#  lens
#    The lens to use
#  changes
#    The changes to make
#  onlyif
#    Optional augeas command and comparisons to control the execution of this type.
#  force
#    Always make the change
#
# Actions:
#   Creates an augeas resource, read http://docs.puppetlabs.com/references/latest/type.html#augeas on how to use this
#
# Depends:
#   gen_puppet
#
define kaugeas ($file, $lens, $changes, $onlyif=false, $force=false) {
  augeas { $name:
    incl    => $file,
    lens    => $lens,
    changes => $changes,
    onlyif  => $onlyif ? {
      false => undef,
      true  => $onlyif,
    },
    force   => $force;
  }
}
