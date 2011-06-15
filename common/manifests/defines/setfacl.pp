define setfacl ($dir = false, $default = false, $acl) {
	if $dir {
		$real_dir = $dir
	} else {
		$real_dir = $name
	}

	if $default {
		if $acl =~ /^default/ {
			fail("Can't make a default ACL if you have already specified default: in the acl. Please fix this.")
		}
		setfacl { "Set default ${acl} for ${real_dir}":
			dir => $real_dir,
			acl => "default:${acl}"
		}
	}

	exec { "Set acls '${acl}' on ${real_dir}":
		command => "/usr/bin/setfacl -R -m ${acl} ${real_dir}",
		unless  => "/usr/bin/getfacl --absolute-names ${real_dir} | /bin/grep '^${acl}'",
		require => Kpackage["acl"],
	}
}
