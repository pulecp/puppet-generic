# Author: Kumina bv <support@kumina.nl>

# Class: gen_trac
#
# Actions:
#  Setup the trac software.
#
class gen_trac($mail_relay=false) {
  package { ["trac"]:
    ensure => installed,
  }

  # Shared Trac configuration
  file { "/etc/trac/trac.ini":
    content => template("gen_trac/trac.ini"),
    owner   => "root",
    group   => "root",
    mode    => 644,
    require => Package["trac"],
  }

  # Directory in which Trac can unpack any Python Eggs
  file { "/var/cache/trac":
    owner  => "www-data",
    group  => "www-data",
    mode   => "0775",
    ensure => "directory",
  }

  file { "/srv/trac":
    ensure => directory;
  }
}

define gen_trac::environment($group, $path=false, $svnrepo=false) {
  include gen_trac

  if $path {
    $tracdir = $path
  } else {
    $tracdir = "/srv/trac/$name"
  }

  if $svnrepo {
    $svndir = $svnrepo
  } else {
    $svndir = "/srv/svn/$name"
  }

  # Create the Trac environment
  exec { "create-trac-${name}":
    command   => "/usr/bin/trac-admin ${tracdir} initenv ${name} sqlite:db/trac.db svn ${svndir}",
    logoutput => false,
    creates   => "${tracdir}/conf/trac.ini",
    require   => Package["trac"],
  }

  # www-data needs read and write access to the trac database,
  # log files, and configuration file (for WebAdmin)
  file {
    ["${tracdir}","${tracdir}/db"]:
      owner   => "www-data",
      group   => $group,
      recurse => false,
      mode    => 0750,
      require => Exec["create-trac-${name}"];
    ["${tracdir}/db/trac.db","${tracdir}/log/trac.log","${tracdir}/conf/trac.ini"]:
      owner   => "www-data",
      group   => $group,
      mode    => 0664,
      require => Exec["create-trac-${name}"];
    ["${tracdir}/log","${tracdir}/conf","${tracdir}/attachments","${tracdir}/templates","${tracdir}/wiki-macros","${tracdir}/htdocs","${tracdir}/plugins"]:
      owner   => "www-data",
      group   => $group,
      mode    => 0775,
      require => Exec["create-trac-${name}"];
  }
}
