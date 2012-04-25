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
define setfacl ($dir=$name, $acl, $make_default=false, $recurse=true, $mask='rwx') {
  $real_r = $recurse ? {
    true    => '-R',
    default => '',
  }

  if $make_default {
    if $acl =~ /^default/ {
      fail("Can't make a default ACL if you have already specified default: in the acl. Please fix this.")
    }

    exec {
      "Set default acls '${acl}' on ${dir}":
        command => "/usr/bin/setfacl ${real_r} -m default:${acl} ${dir}",
        unless  => "/usr/bin/test $(/usr/bin/getfacl --absolute-names ${dir} | /bin/grep '^default:${acl}') -o $(/usr/bin/test ! -e ${dir})",
        timeout => 0,
        require => Package["acl"];
      "Set default acls '${acl}' on ${dir} (mask)":
        command => "/usr/bin/setfacl ${real_r} -n -m default:mask:${mask} ${dir}",
        unless  => "/usr/bin/test $(${dir} && /usr/bin/getfacl --absolute-names ${dir} | /bin/grep '^default:mask::${mask}') -o $(/usr/bin/test ! -e ${dir})",
        timeout => 0,
        require => Package["acl"];
    }
  }

  exec {
    "Set acls '${acl}' on ${dir}":
      command => "/usr/bin/setfacl ${real_r} -m ${acl} ${dir}",
      unless  => "/usr/bin/test $(${dir} && /usr/bin/getfacl --absolute-names ${dir} | /bin/grep '^${acl}') -o $(/usr/bin/test ! -e ${dir})",
      timeout => 0,
      require => Package["acl"];
    "Set acls '${acl}' on ${dir} (mask)":
      command => "/usr/bin/setfacl ${real_r} -n -m mask:${mask} ${dir}",
      unless  => "/usr/bin/test $(${dir} && /usr/bin/getfacl --absolute-names ${dir} | /bin/grep '^mask::${mask}') -o $(/usr/bin/test ! -e ${dir})",
      timeout => 0,
      require => Package["acl"];
  }
}
