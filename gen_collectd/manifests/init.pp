class gen_collectd {
  if $lsbdistcodename != 'lenny' {
    if $lsbdistcodename == 'squeeze' {
      # Pin to backports
      gen_apt::preference { ['collectd','collectd-core','collectd-dbg', 'collectd-dev',
                            'collectd-utils', 'libcollectdclient-dev', 'libcollectdclient0']:;
      }
    }

    kservice { 'collectd':
      package  => 'collectd-core',
      srequire => File['/etc/collectd/collectd.conf'];
    }

    file {
      '/etc/collectd/conf':
        ensure  => directory,
        require => Package['collectd-core'];
      '/etc/collectd/collectd.conf':
        content => 'Include /etc/collectd/conf/';
      '/etc/collectd/conf/1-default.conf':
        content => template('gen_collectd/conf/default.conf');
    }
  }
}

define gen_collectd::plugin ($plugin = false, $pluginconf = false, $loadplugin = false) {
  if ! $plugin {
    $real_plugin = $name
  } else {
    $real_plugin = $plugin
  }

  file { "/etc/collectd/conf/3-${name}":
    content => template('gen_collectd/conf/plugin.conf'),
    require => File['/etc/collectd/conf'];
  }
}
