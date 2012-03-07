# Author: Kumina bv <support@kumina.nl>

# Define: kfile
#
# Parameters:
#  mode
#    Undocumented
#  content
#    Undocumented
#  recurse
#    Undocumented
#  source
#    Undocumented
#  target
#    Undocumented
#  force
#    Undocumented
#  owner
#    Undocumented
#  purge
#    Undocumented
#  group
#    Undocumented
#  ensure
#    Undocumented
#  backup
#    Make a backup of the file in the filebucket
#
# Actions:
#  Undocumented
#
# Depends:
#  gen_puppet
#
define kfile ($ensure="present", $content=false, $source=false, $target=false, $owner="root", $backup=false,
      $group="root", $mode="0644", $recurse=false, $replace=true, $force=false, $purge=false) {
  file { $name:
    ensure  => $ensure,
    content => $content ? {
      false   => undef,
      default => $content,
    },
    source  => $source ? {
      false   => undef,
      default => "puppet:///modules/${source}",
    },
    target  => $target,
    owner   => $owner,
    group   => $group,
    mode    => $ensure ? {
      directory => $mode ? {
        false   => undef,
        "0644"  => "0755",
        default =>  $mode,
      },
      false     => undef,
      default   => $mode,
    },
    recurse => $recurse,
    replace => $replace,
    force   => $force,
    purge   => $purge,
    backup  => $backup;
  }
}
