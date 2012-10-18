# Author: Kumina bv <support@kumina.nl>

# Class: apache
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class gen_apache {
  include gen_base::libapr1

  kservice { "apache2":; }

  # We can safely keep this up-to-date
  package { "apache2-utils":
    ensure => latest,
  }

  exec { "force-reload-apache2":
    command     => "/etc/init.d/apache2 force-reload",
    refreshonly => true,
    require     => Exec["reload-apache2"];
  }

  file {
    "/etc/apache2/vhost-additions":
      ensure  => directory,
      purge   => true,
      recurse => true,
      force   => true,
      require => Package["apache2"];
    "/etc/apache2/sites-enabled":
      ensure  => directory,
      purge   => true,
      recurse => true,
      require => Package["apache2"];
    "/etc/apache2/sites-available":
      ensure  => directory,
      purge   => true,
      recurse => true,
      require => Package["apache2"];
    "/etc/apache2/sites-available/default":
      ensure  => absent;
    "/etc/apache2/sites-available/default-ssl":
      ensure  => absent;
  }

  concat {
    "/etc/apache2/ports.conf":
      require     => Package["apache2"],
      notify      => Exec["reload-apache2"];
    "/etc/apache2/httpd.conf":
      require     => Package["apache2"],
      notify      => Exec["reload-apache2"];
  }

  concat::add_content { "base_httpd":
    content => template("gen_apache/httpd.conf"),
    target  => "/etc/apache2/httpd.conf";
  }
}

class gen_apache::headers {
  gen_apache::module { "headers":; }
}

class gen_apache::jk {
  gen_apache::module { 'jk':
    require => Package['libapache2-mod-jk'];
  }

  package { 'libapache2-mod-jk':; }
}

define gen_apache::site($ensure="present", $serveralias=false, $documentroot="/var/www", $address='*', $address6='::', $make_default=false, $ssl=false, $key=false, $cert=false, $intermediate=false, $wildcard=false, $log_vhost=false,
    $redirect_non_ssl=true, $access_logformat="combined") {
  if $address == $ipaddress {
    fail("${name} has been set specifically to the base IP address, this will cause problems due to * sites being picked up by this vhost as well as it is more specific.")
  }
  if regsubst($name, '^(.*)_.*$', '\1') == $name {
    fail("The gen_apache::site name should include the port, not only ${name}")
  }

  $real_name = regsubst($name, '^(.*)_(.*)$', '\1')
  $port      = regsubst($name, '^(.*)_(.*)$', '\2')

  if ! defined(File[$documentroot]) {
    file { $documentroot:
      ensure  => directory,
      replace => false,
      notify  => Exec["initialize_${documentroot}"];
    }

    exec { "initialize_${documentroot}":
      unless      => "/bin/sh -c \"/usr/bin/test -f ${documentroot}/*\"",
      command     => "/usr/bin/touch ${documentroot}/index.htm",
      refreshonly => true;
    }
  }

  file {
    "/etc/apache2/sites-available/${name}":
      ensure  => $ensure,
      content => template("gen_apache/available_site"),
      require => Package["apache2"],
      notify  => Exec["reload-apache2"];
    "/etc/apache2/vhost-additions/${name}":
      ensure  => $ensure ? {
        present => directory,
        absent  => absent,
      };
    "/etc/apache2/vhost-additions/${name}/${name}":
      ensure  => $ensure,
      content => template("gen_apache/vhost-additions/basic"),
      notify  => Exec["reload-apache2"];
  }

  case $ensure {
    "present": {
      if $real_name == "default" {
        file { "/etc/apache2/sites-enabled/000_${name}":
          ensure => link,
          target => "/etc/apache2/sites-available/${name}",
          notify => Exec["reload-apache2"];
        }
      } else {
        file { "/etc/apache2/sites-enabled/${name}":
          ensure => link,
          target => "/etc/apache2/sites-available/${name}",
          notify => Exec["reload-apache2"];
        }
      }

      if !defined(Concat::Add_content["Listen ${port}"]) {
        concat::add_content { "Listen ${port}":
          target => "/etc/apache2/ports.conf";
        }
      }

      if !defined(Concat::Add_content["NameVirtualHost ${address}:${port}"]) {
        concat::add_content { "NameVirtualHost ${address}:${port}":
          target => "/etc/apache2/httpd.conf";
        }
      }
    }
    "absent": {
      file { "/etc/apache2/sites-enabled/${name}":
        ensure => absent,
        notify => Exec["reload-apache2"];
      }
    }
  }

  if $make_default {
    if $key or $cert or $intermediate or $wildcard or $ssl {
      # Do nothing, we do not support defaulting SSL
    } else {
      gen_apache::forward_vhost { "default":
        ensure      => $ensure,
        address     => $address,
        address6    => $address6,
        teststring  => "%{REQUEST_URI}",
        condpattern => "!^/server-status.*",
        forward     => "http://${real_name}";
      }
    }
  }

  if $key or $cert or $intermediate or $wildcard or $ssl {
    $real_cert = $cert ? {
      false   => $wildcard ? {
        false   => "${real_name}.pem",
        default => "${wildcard}.pem",
      },
      default => "${cert}.pem",
    }
    $real_key = $key ? {
      false   => $wildcard ? {
        false   => "${real_name}.key",
        default => "${wildcard}.key",
      },
      default => "${key}.key",
    }

    file { "/etc/apache2/vhost-additions/${name}/ssl":
      content => template("gen_apache/vhost-additions/ssl"),
      notify  => Exec["reload-apache2"];
    }
  }
}

define gen_apache::module ($ensure = "enable") {
  include gen_apache
  if $ensure == "enable" {
    exec { "/usr/sbin/a2enmod ${name}":
      unless  => "/bin/sh -c '[ -L /etc/apache2/mods-enabled/${name}.load ] && [ /etc/apache2/mods-enabled/${name}.load -ef /etc/apache2/mods-available/${name}.load ]'",
      require => Package["apache2"],
      notify  => Exec["force-reload-apache2"];
    }
  } else {
    # Bit of a hack, but better than a lot of nested ifs, I think
    if $ensure != "disable" { fail("The ensure parameter need to be 'enable' or 'disable', not '${ensure}'.") }

    exec { "/usr/sbin/a2dismod ${name}":
      onlyif  => "/bin/sh -c '[ -L /etc/apache2/mods-enabled/${name}.load ] && [ /etc/apache2/mods-enabled/${name}.load -ef /etc/apache2/mods-available/${name}.load ]'",
      require => Package["apache2"],
      notify  => Exec["force-reload-apache2"];
    }
  }
}

define gen_apache::forward_vhost($ensure="present", $forward, $address = '*', $address6 = '::', $port=80, $serveralias=false, $statuscode=301, $condpattern=false, $teststring="%{HTTP_HOST}", $preserve_path=true) {
  $full_name = "${name}_${port}"
  $substitution = $preserve_path ? {
    true  => "${forward}\$1",
    false => "${forward}",
  }

  gen_apache::site { $full_name:
    ensure      => $ensure,
    address     => $address,
    address6    => $address6,
    serveralias => $serveralias;
  }

  gen_apache::redirect { $full_name:
    site         => $name,
    substitution => $substitution,
    usecond      => $condpattern ? {
      false   => false,
      default => true,
    },
    teststring   => $teststring,
    condpattern  => $condpattern,
    statuscode   => $statuscode;
  }
}

define gen_apache::redirect($site=$fqdn, $port=80, $usecond=true, $condpattern=false, $teststring="%{HTTP_HOST}", $pattern="^(.*)$", $substitution, $statuscode=301, $flags="R=${statuscode}") {
  if $usecond and !$condpattern {
    fail { "A condpattern must be supplied if rewritecond is set to true (gen_apache::redirect ${name}).":; }
  }

  $full_site = "${site}_${port}"

  if !defined(Gen_apache::Rewrite_on[$full_site]) {
    gen_apache::rewrite_on { $full_site:; }
  }

  concat::add_content { $name:
    content => template("gen_apache/vhost-additions/redirect"),
    target  => "/etc/apache2/vhost-additions/${full_site}/redirects";
  }
}

define gen_apache::rewrite_on {
  concat { "/etc/apache2/vhost-additions/${name}/redirects":
    require => File["/etc/apache2/vhost-additions/${name}"],
    notify  => Exec["reload-apache2"];
  }

  concat::add_content { "000_Enable rewrite engine for ${name}":
    content => "RewriteEngine on\n",
    target  => "/etc/apache2/vhost-additions/${name}/redirects";
  }
}

define gen_apache::vhost_addition($ensure="present", $content=false) {
  $full_site_name = regsubst($name,'^(.*)/(.*)$','\1')

  file { "/etc/apache2/vhost-additions/${name}":
    ensure  => $ensure,
    content => $content ? {
      false   => undef,
      default => $content,
    },
    require => Gen_apache::Site[$full_site_name],
    notify  => Exec["reload-apache2"];
  }
}
