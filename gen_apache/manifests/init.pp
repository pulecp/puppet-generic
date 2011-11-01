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

  exec { "force-reload-apache2":
    command     => "/etc/init.d/apache2 force-reload",
    refreshonly => true,
    require     => Exec["reload-apache2"];
  }

  kfile {
    "/etc/apache2/httpd.conf":
      content => template("gen_apache/httpd.conf"),
      require => Package["apache2"];
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

  concat { "/etc/apache2/ports.conf":
    require => Package["apache2"],
    notify  => Exec["reload-apache2"];
  }
}

class gen_apache::headers {
  apache::module { "headers":; }
}

define gen_apache::site($ensure="present", $serveralias=false, $documentroot="/var/www", $create_documentroot=true, $address=false, $address6=false,
    $port=false, $make_default=false, $ssl=false, $key=false, $cert=false, $intermediate=false,
    $redirect_non_ssl=true) {
  $temp_name = $port ? {
    false   => $name,
    default => "${name}_${port}",
  }
  if $key or $cert or $intermediate or $ssl {
    $full_name     = regsubst($temp_name,'^([^_]*)$','\1_443')
    $real_address  = $address ? {
      false   => "*",
      default => $address,
    }
    $real_address6 = $address6 ? {
      false   => "*",
      default => $address6,
    }
  } else {
    $full_name     = regsubst($temp_name,'^([^_]*)$','\1_80')
    $real_address  = "*"
    $real_address6 = "*"
  }
  $real_name = regsubst($full_name,'^(.*)_(.*)$','\1')
  $real_port = regsubst($full_name,'^(.*)_(.*)$','\2')

  if $create_documentroot {
    kfile { $documentroot:
      ensure => directory;
    }
  }

  kfile {
    "/etc/apache2/sites-available/${full_name}":
      ensure  => $ensure,
      content => template("gen_apache/available_site"),
      require => Package["apache2"],
      notify  => Exec["reload-apache2"];
    "/etc/apache2/vhost-additions/${full_name}":
      ensure  => $ensure ? {
        present => directory,
        absent  => absent,
      };
    "/etc/apache2/vhost-additions/${full_name}/${full_name}":
      ensure  => $ensure,
      content => template("gen_apache/vhost-additions/basic"),
      notify  => Exec["reload-apache2"];
  }

  case $ensure {
    "present": {
      if $real_name == "default" {
        kfile { "/etc/apache2/sites-enabled/000_${full_name}":
          ensure => link,
          target => "/etc/apache2/sites-available/${full_name}",
          notify => Exec["reload-apache2"];
        }
      } else {
        kfile { "/etc/apache2/sites-enabled/${full_name}":
          ensure => link,
          target => "/etc/apache2/sites-available/${full_name}",
          notify => Exec["reload-apache2"];
        }
      }

      if !defined(Concat::Add_content["Listen ${real_port}"]) {
        concat::add_content { "Listen ${real_port}":
          target => "/etc/apache2/ports.conf";
        }
      }
    }
    "absent": {
      kfile { "/etc/apache2/sites-enabled/${full_name}":
        ensure => absent,
        notify => Exec["reload-apache2"];
      }
    }
  }

  if $make_default {
    gen_apache::forward_vhost { "default":
      ensure  => $ensure,
      forward => "http://${real_name}";
    }
  }

  if $key or $cert or $intermediate or $ssl {
    kfile { "/etc/apache2/vhost-additions/${full_name}/ssl":
      content => template("gen_apache/vhost-additions/ssl"),
      notify  => Exec["reload-apache2"];
    }

    if $redirect_non_ssl {
      gen_apache::forward_vhost { $real_name:
        ensure      => $ensure,
        forward     => "https://${real_name}$1",
        serveralias => $serveralias;
      }
    }
  }
}

define gen_apache::module {
  exec { "/usr/sbin/a2enmod ${name}":
    unless  => "/bin/sh -c '[ -L /etc/apache2/mods-enabled/${name}.load ] && [ /etc/apache2/mods-enabled/${name}.load -ef /etc/apache2/mods-available/${name}.load ]'",
    require => Package["apache2"],
    notify  => Exec["force-reload-apache2"];
  }
}

define gen_apache::forward_vhost($ensure="present", $port=80, $forward, $serveralias=false) {
  $full_name = "${name}_${port}"

  gen_apache::site { $full_name:
    ensure              => $ensure,
    serveralias         => $serveralias,
    create_documentroot => false;
  }

  gen_apache::redirect { $full_name:
    site         => $name,
    substitution => $forward,
    usecond      => false;
  }
}

define gen_apache::redirect($site=$fqdn, $port=80, $usecond=true, $condpattern=false, $teststring="%{HTTP_HOST}", $pattern="^(.*)$", $substitution, $flags="R=301") {
  if $rewritecond and !$condpattern {
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

define gen_apache::vhost_addition($ensure="present", $content=false, $source=false) {
  $full_site_name = regsubst($name,'^(.*)/(.*)$','\1')
  $site_name = regsubst($full_site_name,'^(.*)_(.*)$','\1')
  if defined(Gen_apache::Site["$site_name"]) {
    $require_name = $site_name
  } else {
    $require_name = $full_site_name
  }

  kfile { "/etc/apache2/vhost-additions/${name}":
    ensure  => $ensure,
    content => $content ? {
      false   => undef,
      default => $content,
    },
    source  => $source ? {
      false   => undef,
      default => $source,
    },
    require => Gen_apache::Site[$require_name],
    notify  => Exec["reload-apache2"];
  }
}
