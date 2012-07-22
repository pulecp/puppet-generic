# Author: Kumina bv <support@kumina.nl>

# Class: gen_varnish
#
# Actions:
#  Setup varnish.
#
# Depends:
#  gen_puppet
#
class gen_varnish {
  kservice { "varnish":
    ensure  => running,
    pensure => latest,
    pnotify => Exec["Clear varnish startup options"];
  }

  # We need to trucate the default varnish startup options file
  exec { "Clear varnish startup options":
    command     => "/bin/echo '' > /etc/default/varnish",
    refreshonly => true,
  }

  Exec["Clear varnish startup options"] -> Gen_varnish::Set_config <| |>
}

# Define: gen_varnish::config
#
# Action:
#  Create global configuration for Varnish.
#
# Parameters:
#   name
#     Not used, use something like 'dummy'. Other resources are created that will cause a duplicate
#     definition if two configs are created. Multiple varnish processes are not (yet?) supported.
#   nfiles
#     Maximum number of open files (for ulimit -n). Defaults to 131072.
#   memlock
#     Maximum locked memory size (for ulimit -l). Defaults to 82000.
#   vcl_conf
#     Main configuration file. Defaults to '/etc/varnish/default.vcl'.
#   listen_address
#     What address to listen on. Empty string means all interfaces. Defaults to '' (all interfaces).
#   listen_port
#     What port to listen on. Defaults to 6081.
#   admin_address
#     Telnet admin listen address. Defaults to '127.0.0.1'.
#   admin_port
#     Telnet admin listen port. Defaults to 6082.
#   min_threads
#     Minimum number of workers that are active. Defaults to 1.
#   max_threads
#     Maximum number of workers that can be active. Defaults to 1000.
#   idle_timeout
#     Time before an idle worker timeout in seconds. Defaults to 120.
#   storage_file
#     Where to keep the on-disk cache storage. This is non-persistent. Defaults to
#     '/var/lib/varnish/varnish_storage.bin'.
#   storage_size
#     Cache file size: in bytes, optionally using k / M / G / T suffix, or in percentage of available
#     disk space using the % suffix. Defaults to '1G'.
#   secret_file
#     File containing administration secret. Defaults to '/etc/varnish/secret'.
#   default_ttl
#     Default TTL used when the backend does not specify one. Defaults to 120.
#
# Depends:
#  gen_varnish
#
define gen_varnish::config ($nfiles='131072',$memlock='82000',$vcl_conf='/etc/varnish/default.vcl',$listen_address='',$listen_port='6081',$admin_address='127.0.0.1',
                            $admin_port='6082',$min_threads='1',$max_threads='1000',$idle_timeout='120',$storage_file='/var/lib/varnish/varnish_storage.bin',
                            $storage_size='1G',$secret_file='/etc/varnish/secret',$default_ttl='120') {
  gen_varnish::set_config {
    "NFILES":  value => $nfiles;
    "MEMLOCK": value => $memlock;
    "START":   value => 'yes';
  }

  gen_varnish::set_config { "DAEMON_OPTS":
      value => "\"-a ${listen_address}:${listen_port} -f ${vcl_conf} -T ${admin_address}:${admin_port} -t ${default_ttl} -w ${min_threads},${max_threads},${idle_timeout} -S ${secret_file} -s file,${storage_file},${storage_size}\"";
  }
}

# Define: gen_varnish::set_config
#
# Action:
#   Internal define that makes setting of global settings easier.
#
# Parameters:
#   name
#     The variable to set.
#   value
#     The value the variable should have.
#
# Depends:
#   gen_puppet
#   kaugeas
#   gen_varnish
#
define gen_varnish::set_config ($value) {
  include gen_varnish

  kaugeas { "Varnish global setting ${name}":
    file    => '/etc/default/varnish',
    require => Package['varnish'],
    lens    => 'Shellvars.lns',
    changes => "set ${name} '${value}'",
    notify  => Service['varnish'],
  }
}
