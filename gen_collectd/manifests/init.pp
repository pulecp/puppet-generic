class gen_collectd {
  if $lsbdistcodename != 'lenny' {
    if $lsbdistcodename == 'squeeze' {
      # Pin to backports
      gen_apt::preference { ['collectd','collectd-core','collectd-dbg', 'collectd-dev',
                            'collectd-utils', 'libcollectdclient-dev', 'libcollectdclient0']:;
      }
    }

    kservice { 'collectd':
      package   => 'collectd-core',
      hasreload => false,
      srequire  => File['/etc/collectd/collectd.conf'];
    }

    file {
      '/etc/collectd/conf':
        ensure  => directory,
        purge   => true,
        recurse => true,
        force   => true,
        require => Package['collectd-core'];
      '/etc/collectd/collectd.conf':
        content => "Include \"/etc/collectd/conf\"\n",
        notify  => Exec['reload-collectd'],
        require => Package['collectd-core'];
      '/etc/collectd/conf/1-default.conf':
        notify  => Exec['reload-collectd'],
        content => template('gen_collectd/conf/default.conf');
      '/usr/lib/collectd/exec-plugins':
        ensure  => directory,
        require => Package['collectd-core'];
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
#  noloadplugin: Don't add 'LoadPlugin "plugin"' to the config
#
#  For the exec plugin, two extra options exist:
#  exec_script: The name of the script as installed with gen_collectd::plugin::exec_script
#
define gen_collectd::plugin ($plugin = false, $pluginconf = false, $noloadplugin = false) {
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

#
# Define: gen_collectd::plugin::exec
#
# Actions:
#  Set up the exec plugin config
#
# Parameters:
#  name: The name that the config will have
#  script: The name of the script installed with gen_collectd::plugin::exec::script
#  as_user: A string containing the user as whom this script is run
#
define gen_collectd::plugin::exec ($script, $as_user='nobody') {
  gen_collectd::plugin { $name:
    plugin       => 'exec',
    noloadplugin => true,
    pluginconf   => {"Exec" => "\"${as_user}\" \"/usr/lib/collectd/exec-plugins/${script}\""},
    require      => File["/usr/lib/collectd/exec-plugins/${script}"];
  }
}

#
# Define: gen_collectd::plugin::exec::script
#
# Actions:
#  Install a script for the exec plugin
#
# Parameters:
#  name:    The name of the script
#  content: The content of the script
#
define gen_collectd::plugin::exec::script ($content) {
  file { "/usr/lib/collectd/exec-plugins/${name}":
    content => $content,
    mode    => 755,
    require => File['/usr/lib/collectd/exec-plugins'];
  }
}
