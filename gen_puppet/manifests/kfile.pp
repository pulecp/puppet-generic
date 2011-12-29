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
#  path
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
#  ignore
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
define kfile ($ensure="present", $content=false, $source=false, $path=false, $target=false, $owner="root", $backup=false,
      $group="root", $mode="0644", $recurse=false, $replace=true, $force=false, $purge=false, $ignore=false) {
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
    path    => $path ? {
      false   => undef,
      default => $path,
    },
    target  => $target ? {
      false   => undef,
      default => $target,
    },
    owner   => $owner ? {
      false   => undef,
      default => $owner,
    },
    group   => $group ? {
      false   => undef,
      default => $group,
    },
    mode    => $ensure ? {
      directory => $mode ? {
        false   => undef,
        "0644"  => "0755",
        default =>  $mode,
      },
      false     => undef,
      default   => $mode,
    },
    recurse => $recurse ? {
      false   => undef,
      default => $recurse,
    },
    replace => $replace,
    force   => $force ? {
      false   => undef,
      default => $force,
    },
    purge   => $purge ? {
      false   => undef,
      default => $purge,
    },
    backup  => $backup,
    ignore  => $ignore ? {
      false   => undef,
      default => $ignore,
    };
  }
}
