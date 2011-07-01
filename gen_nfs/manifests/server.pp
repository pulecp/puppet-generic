# Author: Kumina bv <support@kumina.nl>

# Class: gen_nfs::server
#
# Parameters:
#	failover
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_nfs::server ($failover = false) {
	include gen_nfs

	kpackage { "nfs-kernel-server":
		ensure => "latest",
	}

	# If $failover is false, we assume a single NFS server or a master-master setup.
	if $failover { $nfsd_ensure_running = "false"   }
	else         { $nfsd_ensure_running = "running" }

	service { "nfs-kernel-server":
		ensure     => $nfsd_ensure_running,
		hasstatus  => true,
		hasrestart => true,
		require    => [Kpackage["nfs-kernel-server"],Concat["/etc/default/nfs-common","/etc/default/nfs-kernel-server"]],
	}

	# The mountd service is controlled by nfs-kernel-server, but that status command
	# doesn't check it.
	exec { "/etc/init.d/nfs-kernel-server restart":
		unless => "/bin/pidof rpc.mountd",
	}
}

# Define: gen_nfs::server::config
#
# Parameters:
#	need_idmapd
#		Undocumented
#	need_statd
#		Undocumented
#	need_gssd
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define gen_nfs::server::config ($need_gssd = "no", $need_idmapd = "no", $need_statd = "yes",
				$need_svcgssd = "no", $mountd_port = false, $incoming_port = false,
				$outgoing_port = false, $lock_port = false, $rpcnfsdcount = "8",
				$rpcnfsdpriority = "0", $rpcmountdopts = "", $rpcsvcgssdopts = "",
				$statdopts = "") {
	concat {
		"/etc/default/nfs-common":
			notify => Service["nfs-common"];
		"/etc/default/nfs-kernel-server":
			notify => Service["nfs-kernel-server"];
	}

	# Some helper functions. These can be done by setting the variable
	# itself, but this makes often-used option a bit easier to set.
	if $mountd_port {
		$real_mount_port = " --port ${mountd_port}"
	} else {
		$real_mount_port = ""
	}

	if $incoming_port {
		# If we give an incoming port, we also need an outgoing port
		if ! $outgoing_port { fail("An incoming port also needs an outgoing port.") }
		$real_statd_outgoing = " --outgoing-port ${outgoing_port}"
		$real_statd_incoming = " --port ${incoming_port}"
	} else {
		# If we give an outgoing port, we also need an incoming port
		if $outgoing_port { fail("An outgoing port also needs an incoming port.") }
		$real_statd_incoming = ""
		$real_statd_outgoing = ""
	}

	# The lock daemon is a kernel internal thingy, we need to actually set the
	# kernel module options.
	if $lock_port {
		kfile { "/etc/modprobe.d/lock":
			content => "options lockd nlm_udpport=${lock_port} nlm_tcpport=${lock_port}\n",
		}
	}

	concat::fragment {
		"nfsd need_gssd":
			target  => "/etc/default/nfs-common",
			content => "NEED_GSSD=\"${need_gssd}\"\n";
		"nfsd need_idmapd":
			target  => "/etc/default/nfs-common",
			content => "NEED_IDMAPD=\"${need_idmapd}\"\n";
		"nfsd need_statd":
			target  => "/etc/default/nfs-common",
			content => "NEED_STATD=\"${need_statd}\"\n";
		"nfsd need_svcgssd":
			target  => "/etc/default/nfs-kernel-server",
			content => "NEED_SVCGSSD=\"${need_svcgssd}\"\n";
		"nfsd rpcnfsdcount":
			target  => "/etc/default/nfs-kernel-server",
			content => "RPCNFSDCOUNT=${rpcnfsdcount}\n";
		"nfsd rpcnfsdpriority":
			target  => "/etc/default/nfs-kernel-server",
			content => "RPCNFSDPRIORITY=${rpcnfsdpriority}\n";
		"nfsd rpcmountdopts":
			target  => "/etc/default/nfs-kernel-server",
			content => "RPCMOUNTDOPTS=\"${rpcmountdopts}${real_mount_port}\"\n";
		"nfsd rpcsvcgssdopts":
			target  => "/etc/default/nfs-kernel-server",
			content => "RPCSVCGSSDOPTS=\"${rpcsvcgssdopts}\"\n";
		"nfsd statdopts":
			target  => "/etc/default/nfs-common",
			content => "STATDOPTS=\"${statdopts}${real_statd_outgoing}${real_statd_incoming}\"\n";
	}
}
