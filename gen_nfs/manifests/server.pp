class gen_nfs::server ($failover = "false") {
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
}

define gen_nfs::server::config ($need_gssd = "no", $need_idmapd = "no", $need_statd = "yes", $need_svcgssd = "no", 
				$rpcnfsdcount = "8", $rpcnfsdpriority = "0", $rpcmountdopts = "", 
				$rpcsvcgssdopts = "", $statdoptions = "") {
	concat {
		"/etc/default/nfs-common":
			notify => Service["nfs-common"];
		"/etc/default/nfs-kernel-server":
			notify => Service["nfs-kernel-server"];
	}

	concat::fragment {
		"nfsd need_gssd":
			target  => "/etc/default/nfs-kernel-server",
			content => "NEED_GSSD = \"${need_gssd}\"";
		"nfsd need_idmapd":
			target  => "/etc/default/nfs-common",
			content => "NEED_IDMAPD = \"${need_idmapd}\"";
		"nfsd need_statd":
			target  => "/etc/default/nfs-common",
			content => "NEED_STATD = \"${need_statd}\"";
		"nfsd need_svcgssd":
			target  => "/etc/default/nfs-kernel-server",
			content => "NEED_SVCGSSD = \"${need_svcgssd}\"";
		"nfsd rpcnfsdcount":
			target  => "/etc/default/nfs-kernel-server",
			content => "RPCNFSDCOUNT = ${rpcnfsdcount}";
		"nfsd rpcnfsdpriority":
			target  => "/etc/default/nfs-kernel-server",
			content => "RPCNFSDPRIORITY = ${rpcnfsdpriority}";
		"nfsd rpcmountdopts":
			target  => "/etc/default/nfs-kernel-server",
			content => "RPCMOUNTDOPTS = \"${rpcmountdopts}\"";
		"nfsd rpcsvcgssdopts":
			target  => "/etc/default/nfs-kernel-server",
			content => "RPCSVCGSSDOPTS = \"${rpcsvcgssdopts}\"";
		"nfsd statdopts":
			target  => "/etc/default/nfs-common",
			content => "STATD_OPTS = \"${statdopts}\"";
	}
}
