class gen_mediawiki {
  package { "mediawiki":
      ensure => latest;
  }
}

class gen_mediawiki::extensionbase {
  package { ["mediawiki-extensions-base","mediawiki-extensions-fckeditor"]:
    ensure => latest;
  }
}

define gen_mediawiki::site {
  include gen_mediawiki

  # This is fairly a hack, so we can setup multiple mediawiki installations
  # using the Debian package. Upgrades will probably fail, though.
  file {
    "${name}/api.php":
      ensure => link,
      target => "/usr/share/mediawiki/api.php";
    "${name}/img_auth.php":
      ensure => link,
      target => "/usr/share/mediawiki/img_auth.php";
    "${name}/includes":
      ensure => link,
      target => "/usr/share/mediawiki/includes";
    "${name}/index.php":
      ensure => link,
      target => "/usr/share/mediawiki/index.php";
    "${name}/install-utils.inc":
      ensure => link,
      target => "/usr/share/mediawiki/install-utils.inc";
    "${name}/languages":
      ensure => link,
      target => "/usr/share/mediawiki/languages";
    "${name}/maintenance":
      ensure => link,
      target => "/usr/share/mediawiki/maintenance";
    "${name}/opensearch_desc.php":
      ensure => link,
      target => "/usr/share/mediawiki/opensearch_desc.php";
    "${name}/profileinfo.php":
      ensure => link,
      target => "/usr/share/mediawiki/profileinfo.php";
    "${name}/redirect.php":
      ensure => link,
      target => "/usr/share/mediawiki/redirect.php";
    "${name}/redirect.phtml":
      ensure => link,
      target => "/usr/share/mediawiki/redirect.phtml";
    "${name}/skins":
      ensure => link,
      target => "/usr/share/mediawiki/skins";
    "${name}/StartProfiler.php":
      ensure => link,
      target => "/usr/share/mediawiki/StartProfiler.php";
    "${name}/thumb.php":
      ensure => link,
      target => "/usr/share/mediawiki/thumb.php";
    "${name}/trackback.php":
      ensure => link,
      target => "/usr/share/mediawiki/trackback.php";
    "${name}/wiki.phtml":
      ensure => link,
      target => "/usr/share/mediawiki/wiki.phtml";
    "${name}/config/index.php":
      ensure => link,
      target => "/var/lib/mediawiki/config/index.php";
    "${name}/config/index.php5":
      ensure => link,
      target => "/var/lib/mediawiki/config/index.php5";
  }

  file {
    ["${name}/config","${name}/images"]:
      ensure => directory,
      owner  => "www-data",
      group  => "www-data",
      mode   => 700;
    "${name}/extensions":
      ensure => directory;
  }

  # These config files are created by the installation procedure, we
  # need to make sure they are writable.
  file { ["${name}/AdminSettings.php","${name}/LocalSettings.php"]:
    owner => "www-data";
  }
}

define gen_mediawiki::extension ($sitepath, $extrapath="base/", $linkname=$name) {
  include gen_mediawiki::extensionbase

  file { "${sitepath}/extensions/${name}":
    ensure => link,
    target => "/usr/share/mediawiki-extensions/${extrapath}${linkname}";
  }
}
