# Author: Kumina bv <support@kumina.nl>

# Define: setfacl
#
# Parameters:
#	make_default
#		Undocumented
#	acl
#		Undocumented
#	dir
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define setfacl ($dir=false, $acl, $make_default = false) {
  $real_dir = $dir ? {
    false   => $name,
    default => $dir,
  }

  if $make_default {
    if $acl =~ /^default/ {
      fail("Can't make a default ACL if you have already specified default: in the acl. Please fix this.")
    }

    setfacl { "Set default ${acl} for ${real_dir}":
      dir => $real_dir,
      acl => "default:${acl}",
    }
  }

  exec { "Set acls '${acl}' on ${real_dir}":
    command => "/usr/bin/setfacl -R -m ${acl} ${real_dir}",
    unless  => "/usr/bin/getfacl --absolute-names ${real_dir} | /bin/grep '^${acl}'",
    require => Kpackage["acl"];
  }
}
