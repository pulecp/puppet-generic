class gen_vim {
	kpackage { "vim":
		ensure => latest,
	}
}

class gen_vim::addon_manager {
	kpackage { "vim-addon-manager":
		ensure => "latest";
	}
}

define gen_vim::global_setting {
	line { "global vim setting ${name}":
		ensure  => "present",
		file    => "/etc/vim/vimrc",
		content => "${name}",
	}
}

define gen_vim::addon ($package=false) {
	# Install and activate a vim addon. Use as follows:
	# kbp_vim::vim_addon { "puppet": package => "vim-puppet"; }
	include gen_vim::addon_manager

	$the_package = $package ? {
		false   => $name,
		default => $package,
	}

	kpackage { $the_package:
		ensure => latest;
	}

	exec { "/usr/bin/vim-addons -w install ${name}":
		unless  => "/usr/bin/vim-addons -w -q show ${name} | /bin/grep 'installed' 2>&1 > /dev/null",
		require => Kpackage["vim-addon-manager", "${the_package}"];
	}
}
