class gen_drbd::common {
  package { "drbd8-utils":; }

  exec { "drbd-remove-symlinks":
    onlyif  => "/usr/bin/test -f /etc/rc2.d/S70drbd",
    command => "/usr/sbin/update-rc.d -f drbd remove",
    require => Package["drbd8-utils"];
  }

  service { "drbd":
    ensure     => running,
    hasrestart => true,
    hasstatus  => true,
    enable     => true,
    require    => [File["/etc/drbd.d/global_common.conf"],Exec["drbd-remove-symlinks"]],
  }
}

define gen_drbd($mastermaster=true, $time_out=false, $connect_int=false, $ping_int=false, $ping_timeout=false, $after_sb_0pri="discard-younger-primary",
    $after_sb_1pri="discard-secondary", $after_sb_2pri="call-pri-lost-after-sb", $rate="5M", $verify_alg="md5", $use_ipaddress=$external_ipaddress, $device_name=$name,
    $disk_flushes=true,$max_buffers=false,$unplug_watermark=false,$sndbuf_size=false,$al_extents=false) {
  include gen_drbd::common

  if !defined(File["/etc/drbd.d/global_common.conf"]) {
    file { "/etc/drbd.d/global_common.conf":
      content => template("gen_drbd/global_common.conf"),
      require => Package["drbd8-utils"],
      notify  => Service["drbd"];
    }
  }

  concat { "/etc/drbd.d/${device_name}.res":
    require => Package["drbd8-utils"],
    notify  => Service["drbd"];
  }

  if !defined(Concat::Add_content["0_${device_name}"]) {
    concat::add_content { "0_${device_name}":
      content => template("gen_drbd/resource_base"),
      target  => "/etc/drbd.d/${device_name}.res";
    }
  }

  @@concat::add_content { "1_${device_name}_${fqdn}":
    content => template("gen_drbd/resource_address"),
    target  => "/etc/drbd.d/${device_name}.res",
    tag     => "drbd_${environment}_${name}";
  }

  Concat::Add_content <<| tag == "drbd_${environment}_${name}" |>>
}
