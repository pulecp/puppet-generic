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
			source  => "libvirt/libvirtd.conf",
			require => Package["libvirt-bin"],
			notify  => Service["libvirt-bin"];
		"/usr/local/sbin/create-vm.sh":
			source  => "create-vm.sh",
			mode    => 755,
			require => Package["libvirt-bin"];
	}
}
