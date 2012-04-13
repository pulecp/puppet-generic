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
define setfacl ($dir, $acl, $make_default = false) {
  if $make_default {
    if $acl =~ /^default/ {
      fail("Can't make a default ACL if you have already specified default: in the acl. Please fix this.")
    }
    setfacl { "Set default ${acl} for ${dir}":
      dir => $dir,
      acl => "default:${acl}",
    }
  }

  exec { "Set acls '${acl}' on ${dir}":
    command => "/usr/bin/setfacl -R -m ${acl} ${dir}",
    unless  => "/usr/bin/getfacl --absolute-names ${dir} | /bin/grep '^${acl}'",
    require => Kpackage["acl"];
  }
}
