# Author: Kumina bv <support@kumina.nl>

# Class: gen_apt
#
# Actions:
#  Set up apt preferences using concat when on Lenny or older and a .d dir otherwise. Set up apt sources using a .d dir.
#
# Depends:
#  gen_puppet
#
class gen_apt {
  if $lsbmajdistrelease < 6 {
    $preferences_file = "/etc/apt/preferences"

    concat { $preferences_file:
      mode => 440;
    }
  } else {
    file { "/etc/apt/preferences":
      ensure => absent;
    }
  }

  file {
    # Putting files in a directory is much easier to manage with
    # Puppet than modifying /etc/apt/sources.lists.
    "/etc/apt/sources.list":
      ensure => absent,
      notify => Exec["/usr/bin/apt-get update"];
    "/etc/apt/sources.list.d":
      ensure => directory,
      notify => Exec["/usr/bin/apt-get update"];
    "/etc/apt/keys":
      ensure => directory;
    # Increase the available cachesize
    "/etc/apt/apt.conf.d/50cachesize":
      content => "APT::Cache-Limit \"33554432\";\n",
      notify  => Exec["/usr/bin/apt-get update"];
  }

  # Run apt-get update when anything beneath /etc/apt/sources.list.d changes
  exec { "/usr/bin/apt-get update":
    refreshonly => true;
  }
}

# Define: gen_apt::preference
#
# Parameters:
#  repo
#    The repo to pin on, defaults to ${lsbdistcodename}-backports
#  version
#    The version to pin on, defaults to false
#  prio
#    The prio to give to the pin, defaults to 999
#  package
#    The package to pin, defaults to ${name}
#
# Actions:
#  Pins a package to a specific version or repo
#
# Depends:
#  gen_puppet
#
define gen_apt::preference($package=false, $repo=false, $version=false, $prio="999") {
  $use_repo = $version ? {
    false   => $repo ? {
      false   => "${lsbdistcodename}-backports",
      default => $repo,
    },
    default => $repo,
  }
  $sanitized_name = regsubst($name, '[^a-zA-Z0-9\-_]', '_', 'G')

  if $lsbmajdistrelease < 6 {
    concat::add_content { $name:
      content => template("gen_apt/preference"),
      target  => "/etc/apt/preferences",
      notify  => Exec["/usr/bin/apt-get update"];
    }
  } else {
    file { "/etc/apt/preferences.d/${sanitized_name}":
      content => template("gen_apt/preference"),
      notify  => Exec["/usr/bin/apt-get update"];
    }
  }
}

# Define: gen_apt::source
#
# Parameters:
#  name
#    The package to define the source of
#  sourcetype
#    The type of the source, defaults to deb
#  distribution
#    The distribution of the source, defaults to stable
#  components
#    An array of components, for example main, nonfree, contrib, defaults to []
#  ensure
#    Defines if the source should be present, options are present and false, defaults to present
#  comment
#    Adds a comment to the source, defaults to false
#  uri
#    The uri of the source
#  key
#    The key used for this repository, if defined.
#  ssl
#    If true turns on ssl
#  user
#    The username to use to connect to the source
#  pass
#    The password to use to connect to the source
#
# Actions:
#  Adds a source entry in the apt config.
#
# Depends:
#  gen_puppet
#
define gen_apt::source($uri, $sourcetype="deb", $distribution="stable", $components=[], $ensure="present", $comment=false, $key=false, $ssl=false, $user=false, $pass=false) {
  file { "/etc/apt/sources.list.d/${name}.list":
    ensure  => $ensure,
    content => template("gen_apt/source.list"),
    require => $key ? {
        false   => File["/etc/apt/sources.list.d"],
        default => [File["/etc/apt/sources.list.d"],Gen_apt::Key[$key]],
      },
    notify  => Exec["/usr/bin/apt-get update"];
  }
}

# Define: gen_apt::key
#
# Actions:
#  Import a repo key, where the key is local to the module. Keep in mind that even when the key comes out of a package, you still need to
#  add it as a file in puppet. Otherwise you need to install the keychain package, which is probably not signed with a default key, before
#  you have the key available. This is unsafe and actually puppet doesn't allow you to ignore the error apt-get gives you at that time.
#
# Parameters:
#  name
#    The key to import.
#  content
#    The key.
#
# Depends:
#  gen_puppet
#
define gen_apt::key ($content) {
  exec { "/usr/bin/apt-key add /etc/apt/keys/${name}":
    unless  => "/usr/bin/apt-key list | grep -q ${name}",
    require => File["/etc/apt/keys/${name}"],
    notify  => Exec["/usr/bin/apt-get update"];
  }

  file { "/etc/apt/keys/${name}":
    content => $content;
  }
}

# Class: gen_apt::cron_apt
#
# Actions:
#  Install cron-apt
#
# Depends:
#  gen_puppet
#
class gen_apt::cron_apt {
  kpackage { "cron-apt":
    ensure => latest;
  }

  concat {"/etc/cron.d/cron-apt":;}
}

# Define: gen_apt::cron_apt::config
#
# Actions:
#  Create configuration for cron-apt
#
# Parameters:
#  configfile
#    The path to the config file for cron_apt
#  mailto
#    Where the cron-apt email should go to; see /usr/share/doc/cron-apt/examples/config
#  mailon
#    The condition cron-apt should mail on; see /usr/share/doc/cron-apt/examples/config
#  apt_options
#    Additional parameters to pass to apt-get; see /usr/share/doc/cron-apt/examples/config
#  apt_hostname
#    The hostname to put in the subject of the email; see /usr/share/doc/cron-apt/examples/config
#  crontime
#    The time to start the apt-get update (in cron format, like 0 4 * * * for 4 o'clock every night)
#
# Depends:
#  gen_puppet
#  gen_apt::cron_apt
#
define gen_apt::cron_apt::config ($mailto, $mailon, $apt_options="", $apt_hostname=false, $configfile="/etc/cron-apt/config", $crontime="0 3 * * *") {
  include gen_apt::cron_apt

  $config_hostname = $apt_hostname ? {
    false   => $fqdn,
    default => $apt_hostname,
  }

  file { $configfile:
    content => template("gen_apt/cron_apt_configfile"),
    require => Kpackage["cron-apt"];
  }

  $safe_configfile = regsubst($configfile, '/', '_')

  concat::add_content { $safe_configfile:
    target  => "/etc/cron.d/cron-apt",
    content => template("gen_apt/cron_apt_cron"),
    require => File[$configfile];
  }
}
