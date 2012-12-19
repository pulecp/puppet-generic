# Author: Kumina bv <support@kumina.nl>

# Class: libvirt
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class libvirt ($on_crash="destroy", $on_reboot="restart") {
  package { ["libvirt-bin","libvirt-doc","netcat-openbsd"]:
    ensure => latest;
  }

  service { "libvirt-bin":
    hasrestart => true,
    hasstatus  => true,
    require    => Package["libvirt-bin"];
  }

  # qemu can be used for testing
  $hypervisor = $is_virtual ? {
    true    => 'qemu',
    'true'  => 'qemu',
    default => 'kvm',
  }

  file {
    "/etc/libvirt/libvirtd.conf":
      content  => template("libvirt/libvirtd.conf"),
      require  => Package["libvirt-bin"],
      notify   => Service["libvirt-bin"];
    "/usr/local/sbin/create-vm.sh":
      content  => template("libvirt/create-vm.sh"),
      group    => "staff",
      mode     => 750,
      require  => Package["libvirt-bin"];
  }
}
