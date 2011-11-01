# Author: Kumina bv <support@kumina.nl>

# Define: ekfile
#
# Parameters:
#  mode
#    Undocumented
#  source
#    Undocumented
#  recurse
#    Undocumented
#  path
#    Undocumented
#  target
#    Undocumented
#  content
#    Undocumented
#  force
#    Undocumented
#  owner
#    Undocumented
#  purge
#    Undocumented
#  group
#    Undocumented
#  ignore
#    Undocumented
#  ensure
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define ekfile ($ensure="present", $source=false, $path=false, $target=false, $content=false, $owner="root", $group="root", $mode="644", $recurse=false, $force=false, $purge=false, $ignore=false) {
  $kfilename = regsubst($name,'^(.*);.*$','\1')
  if !defined(Kfile["${kfilename}"]) {
    kfile { "${kfilename}":
      ensure  => $ensure,
      source  => $source,
      path    => $path,
      target  => $target,
      content => $content,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      recurse => $recurse,
      force   => $force,
      purge   => $purge,
      ignore  => $ignore,
    }
  }
}
