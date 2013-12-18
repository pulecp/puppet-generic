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
        content => 'Include /etc/collectd/conf/',
        require => Package['collectd-core'];
      '/etc/collectd/conf/1-default.conf':
        content => template('gen_collectd/conf/default.conf');
    }
  }
}

#
# Define: gen_collectd::plugin
#
# Actions:
#  Create the config for a plugin
#
# Parameters:
#  name:       If the plugin is unique, just make this the name of the plugin
#  plugin:     If the name is used to differentiate, use this parameter to set the real plugin name
#  pluginconf: A Hash containing the config for this plugin. An example:
#              {"Listen 1.2.3.4" => {"Authfile" => "/etc/auth", "Option1"=> 15}, "Speak 5.6.7.8" => {"Monkey" => "true"}, "Option3" => "false"}
#               expands to:
#               <Listen 1.2.3.4>
#                 Authfile "/etc/auth"
#                 Option1 15
#               </Listen>
#               <Speak 5.6.7.8>
#                 Monkey true
#               </Speak>
#               Option3 false
#
#  loadplugin: Add 'LoadPlugin "plugin"' to the config
#
define gen_collectd::plugin ($plugin = false, $pluginconf = false, $loadplugin = false) {
  if ! $plugin {
    $real_plugin = $name
  } else {
    $real_plugin = $plugin
  }

  file { "/etc/collectd/conf/3-${name}":
    content => template('gen_collectd/conf/plugin.conf'),
    require => File['/etc/collectd/conf'],
    notify  => Exec['reload-collectd'];
  }
}
