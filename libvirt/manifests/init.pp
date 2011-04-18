class libvirt {
	kpackage { ["libvirt-bin","libvirt-doc","netcat-openbsd"]:
		ensure => latest;
	}

	service { "libvirt-bin":
		hasrestart => true,
		hasstatus  => true,
		require    => Package["libvirt-bin"];
	}

	kfile {
		"/etc/libvirt/libvirtd.conf":
			source  => "libvirt/libvirt/libvirtd.conf",
			require => Package["libvirt-bin"],
			notify  => Service["libvirt-bin"];
		"/usr/local/sbin/create-vm.sh":
			source  => "libvirt/create-vm.sh",
			group   => "staff",
			mode    => 750,
			require => Package["libvirt-bin"];
	}
}
