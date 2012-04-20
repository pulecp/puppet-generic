# Author: Kumina bv <support@kumina.nl>

# Define: setfacl
#
# Parameters:
#  make_default
#    Undocumented
#  acl
#    Undocumented
#  dir
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define setfacl ($dir=false, $acl, $make_default = false, $recurse = true, $mask = "rwx") {
  $real_dir = $dir ? {
    false   => $name,
    default => $dir,
  }

  $real_r = $recurse ? {
    true    => "-R",
    default => "",
  }

  if $make_default {
    if $acl =~ /^default/ {
      fail("Can't make a default ACL if you have already specified default: in the acl. Please fix this.")
    }

    exec {
      "Set default acls '${acl}' on ${real_dir}":
        command => "/usr/bin/setfacl ${real_r} -m default:${acl} ${real_dir}",
        unless  => "/usr/bin/getfacl --absolute-names ${real_dir} | /bin/grep '^default:${acl}'",
        require => Package["acl"];
      "Set default acls '${acl}' on ${real_dir} (mask)":
        command => "/usr/bin/setfacl ${real_r} -n -m default:mask:${mask} ${real_dir}",
        unless  => "/usr/bin/getfacl --absolute-names ${real_dir} | /bin/grep '^default:mask::${mask}'",
        require => Package["acl"];
    }
  }

  exec {
    "Set acls '${acl}' on ${real_dir}":
      command => "/usr/bin/setfacl ${real_r} -m ${acl} ${real_dir}",
      unless  => "/usr/bin/getfacl --absolute-names ${real_dir} | /bin/grep '^${acl}'",
      require => Package["acl"];
    "Set acls '${acl}' on ${real_dir} (mask)":
      command => "/usr/bin/setfacl ${real_r} -n -m mask:${mask} ${real_dir}",
      unless  => "/usr/bin/getfacl --absolute-names ${real_dir} | /bin/grep '^mask::${mask}'",
      require => Package["acl"];
  }
}
