# Author: Kumina bv <support@kumina.nl>

# Class: gen_nfs
#
# Actions:
#  Set up nfs-common and portmap
#
# Depends:
#  gen_puppet
#
class gen_nfs {
  kservice {
    "nfs-common":
      hasreload => false;
  }

  if $lsbdistcodename == 'lenny' {
    kservice {
      "portmap":
        hasstatus => false,
        pattern   => "/sbin/portmap",
        require   => Package["nfs-common"];
    }
  } else {
    kservice {
      "portmap":
        require   => Package["nfs-common"];
    }
  }
}

# Class: gen_nfs::server
#
# Parameters:
#  rpcmountdopts
#    The mountd options
#  statdopts
#    The statd options
#  failover
#    Defines whether the nfs server runs in failover
#  need_gssd
#    Same as nfs config, defaults to "no"
#  need_idmapd
#    Same as nfs config, defaults to "no"
#  need_statd
#    Same as nfs config, defaults to "yes"
#  need_svcgssd
#    Same as nfs config, defaults to "no"
#  mountd_port
#    The port for mountd
#  incoming_port
#    The incoming port for statd
#  outgoing_port
#    The outgoiong port for statd
#  lock_port
#    The port for lockd
#  rpcnfsdcount
#    Same as nfs config, defaults to 8
#  rpcnfsdpriority
#    Same as nfs config, defaults to 0
#  rpcsvcgssdopts
#    Same as nfs, defaults to ""
#
# Actions:
#  Set up a nfs server
#
# Depends:
#  gen_puppet
#
class gen_nfs::server ($rpcmountdopts, $statdopts, $need_gssd="no", $need_idmapd="no", $need_statd="yes",
    $need_svcgssd="no", $mountd_port=false, $incoming_port=false, $outgoing_port=false, $lock_port=false, $rpcnfsdcount="8",
    $rpcnfsdpriority="0", $rpcsvcgssdopts="", $failover_ip=false) {
  include gen_nfs

#  Service <| title == "portmap" |> {
#    enable => true,
#    ensure => "running",
#    notify => Service["nfs-common"],
#  }

#  Service <| title == "nfs-common" |> {
#    enable => true,
#    ensure => "running",
#    notify => $failover_ip ? {
#      false => Service["nfs-kernel-server"],
#      default => Exec["reload-nfsd"],
#    },
#  }

  if $failover_ip {
    kservice { "nfs-kernel-server":
      enable  => false,
      ensure  => "undef",
      pensure => "latest";
    }
  } else {
    kservice { "nfs-kernel-server":
      enable  => true,
      ensure  => "running",
      pensure => "latest";
    }
  }

  if $lsbdistcodename != 'lenny' {
    $nfsinit = "/usr/sbin/service nfs-kernel-server"
  } else {
    $nfsinit = "/etc/init.d/nfs-kernel-server"
  }

  exec {
    # only reloads nfs server if it is running; useful for active/standby clusters
    "reload-nfsd":
      command     => "${nfsinit} reload",
      onlyif      => "${nfsinit} status 2>&1 >/dev/null",
      refreshonly => true;
    # reload /etc/exports; succeeds even if nfs server isn't running
    "export-nfsd":
      command     => "/usr/sbin/exportfs -r",
      refreshonly => true;
  }

  # The lock daemon is a kernel internal thingy, we need to actually set the kernel module options.
  if $lock_port {
    file { "/etc/modprobe.d/lock":
      content => "options lockd nlm_udpport=${lock_port} nlm_tcpport=${lock_port}\n";
    }
  }

  # The mountd service is controlled by nfs-kernel-server, but that status command doesn't check it.
  exec { "${nfsinit} restart":
    onlyif  => "${nfsinit} status 2>&1 >/dev/null && ! /bin/pidof rpc.mountd",
    require => Package["nfs-kernel-server"];
  }

  file {
    "/etc/default/nfs-common":
      content => template("gen_nfs/nfs-common"),
      notify  => Service["nfs-common"];
    "/etc/default/nfs-kernel-server":
      content => template("gen_nfs/nfs-kernel-server"),
      notify  => Service["nfs-kernel-server"];
  }
}

# Define: gen_nfs::mount
#
# Parameters:
#  source
#    The url of the nfs server
#
# Actions:
#  Mount a nfs share
#
# Depends:
#  gen_puppet
#
define gen_nfs::mount($source, $options="wsize=1024,rsize=1024") {
  include gen_nfs

  mount { $name:
    ensure   => "mounted",
    device   => $source,
    fstype   => "nfs",
    options  => $options,
    dump     => 0,
    pass     => 0,
    remounts => false,
    require  => [Package["nfs-common"], File[$name]];
  }

  if ! defined(File[$name]) {
    file { $name:
      ensure => directory;
    }
  }
}
