# Author: Kumina bv <support@kumina.nl>

# Class: gen_cifs
#
# Actions:
#  Install CIFS (Common Internet File System, also known as SMB, see http://en.wikipedia.org/wiki/Server_Message_Block) tools
#
# Depends:
#  gen_puppet
#
class gen_cifs {
  package { "cifs-utils":
    ensure => latest,
  }
}

# Class: gen_cifs::configdir
#
# Actions:
#  Create directory for credentials files
#
# Depends:
#  gen_puppet
#
class gen_cifs::configdir {
  file { "/etc/cifs":
    ensure => directory,
    mode   => 700;
  }
}

# Define: gen_cifs::mount
#
# Actions:
#  Mount CIFS share from remote server
#
# Parameters:
#   name
#    Mountpoint
#   ensure
#    Same values as mount resource (http://docs.puppetlabs.com/references/stable/type.html#mount), default 'mounted'
#   createdir (bool)
#    Create mountpoint, default true
#   unc
#    Uniform Naming Convention (http://en.wikipedia.org/wiki/Path_%28computing%29#Uniform_Naming_Convention), e.g. //servername/sharename/foo
#   options
#    Mount options, default 'rw'
#   username
#    CIFS username
#   password
#    CIFS password
#   domain
#    CIFS domain
#   user
#    The user that the files and dirs in the mount belong to (used when the SMB server does not support unix-type file permissions)
#   group
#    The group that the files and dirs in the mount belong to (used when the SMB server does not support unix-type file permissions)
#   dir_perms
#    The permissions of the directories within the mount in OCTAL (used when the SMB server does not support unix-type file permissions)
#   file_perms
#    The permissions of the files within the mount in OCTAL (used when the SMB server does not support unix-type file permissions)
#
# Depends:
#  gen_puppet
#
define gen_cifs::mount($ensure='mounted', $createdir=true, $user='root', $group='root', $dir_perms='0755', $file_perms='0644', $unc, $options='rw', $username, $password, $domain) {
  include gen_cifs::configdir
  include gen_cifs

  $credsfile = regsubst($unc, '[^a-zA-Z0-9\-_]', '_', 'G')

  if $createdir {
    if !defined(File[$name]) {
      file { $name:
        ensure => directory,
        owner  => $user,
        group  => $group,
        mode   => $dir_perms,
      }
    }
  }

  file { "/etc/cifs/${credsfile}":
    ensure  => $ensure ? {
      'absent' => absent,
      false    => absent,
      default  => present,
    },
    content => "username=${username}\npassword=${password}\ndomain=${domain}\n",
    mode    => 600;
  }

  mount { $name:
    ensure  => $ensure,
    fstype  => 'cifs',
    device  => $unc,
    options => "${options},gid=${group},uid=${user},file_mode=${file_perms},dir_mode=${dir_perms},credentials=/etc/cifs/${credsfile}",
    require => $createdir ? {
      false =>   [File["/etc/cifs/${credsfile}"],Package["cifs-utils"]],
      default => [File[$name],File["/etc/cifs/${credsfile}"],Package["cifs-utils"]],
    };
  }
}
