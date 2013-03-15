# Author: Kumina bv <support@kumina.nl>

# Class: gen_samba::server
#
# Actions: Setup the samba server.
#
# Parameters:
#  bindaddress: The address to bind to. Can also be an interface name. Defaults to false, which makes it bind to everything.
#  servername: The name of the server. Defaults to '$hostname'.
#  workgroup: The name of the workgroup for this server. Defaults to 'KUMINA'.
#
class gen_samba::server ($bindaddress=false, $servername=$hostname, $workgroup='KUMINA') {
  package { 'samba-common-bin':; }

  kservice { 'samba':; }

  concat { '/etc/samba/smb.conf':
    notify  => Exec['reload-samba'],
    require => Package['samba'];
  }

  concat::add_content { 'global_smb_config':
    target  => '/etc/samba/smb.conf',
    order   => 5,
    notify  => Service['samba'],
    content => template('gen_samba/smb_global.conf');
  }
}

# Class: gen_samba::clean
#
# Actions: Clean everything around samba. It needs lots of cleaning.
#
class gen_samba::clean {
  $usernames = split($samba_users,'[;:]')

  gen_samba::clean_database { $usernames:; }
}

# Define: gen_samba::share
#
# Actions: Setup a samba share.
#
# Parameters:
#  name: Name of the share.
#  dir: The directory to share under this name.
#  comment: The long, pretty name for this share. Browser can see this. Defaults to the $name.
#  readonly: Whether the share should be read-only. Defaults to true.
#  createmask: The permissions to set on new files. Defaults to 0664.
#  directorymask: The permissions to set on new directories. Defaults to 0775.
#  browseable: If the share should be visible if a visitor just connects to the server. Defaults to false.
#
define gen_samba::share ($dir, $comment=$name, $readonly=true, $createmask='0664', $directorymask='0775', $browseable=false) {
  concat::add_content { "samba_share_${name}_config":
    target => '/etc/samba/smb.conf',
    order  => 50,
    content => template('gen_samba/share.conf');
  }
}

# Define: gen_samba::user
#
# Action: Setup a user to use the samba share. This requires a system user with the same name! You also want to add a 'before' parameter
#         set to Class['gen_samba::clean'], if you use that class to keep the user database clean.
#
# Parameters:
#  name: Username of the Samba user.
#  ensure: Whether the user should be present or absent. Defaults to 'present'.
#  password: The password to use for this Samba user. Yes, it's pretty bad to put it in the puppet code, but I don't have a better way currently.
#
define gen_samba::user ($ensure='present',$password) {
  if $ensure == 'present' {
    if ! ($name in split($samba_users,'[;:]')) {
      exec { "Setup samba user for ${name}":
        command => "/bin/echo -e \"${password}\n${password}\n\" | /usr/bin/smbpasswd -s -a ${name}",
        require => [Package['samba-common-bin'],User[$name]];
      }
    }
  } elsif $ensure == 'absent' {
    if $name in split($samba_users,'[;:]') {
      exec { "Remove samba user for ${name}":
        command => "/usr/bin/smbpasswd -x ${name}",
        require => Package['samba-common-bin'];
      }
    }
  } else {
    fail("Unknown ensure value '${ensure}'.")
  }
}

# Define: gen_samba::clean_database
#
# Action: This removes any user that's not explicitely created in the puppet config.
#
# Parameters:
#  name: Name of the user to check.
#
# Example usage:
#   gen_samba::clean_database { $samba_users:; }
#
define gen_samba::clean_database {
  if ! defined(Gen_samba::User[$name]) {
    exec { "Remove samba user for ${name}":
      command => "/usr/bin/smbpasswd -x ${name}",
      require => Package['samba-common-bin'];
    }
  }
}
