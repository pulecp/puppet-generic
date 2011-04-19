# Copyright (C) 2010 Kumina bv, Ed Schouten <ed@kumina.nl>
# This works is published under the Creative Commons Attribution-Share 
# Alike 3.0 Unported license - http://creativecommons.org/licenses/by-sa/3.0/
# See LICENSE for the full legal text.

class grub {
	package { "grub-pc":
		ensure => installed,
	}

	kfile { "/etc/default/grub":
		source  => "grub/grub-default",
		notify  => Exec["/usr/sbin/update-grub"],
		require => Package["grub-pc"];
	}

	exec { "/usr/sbin/update-grub":
		refreshonly => true,
	}
}
