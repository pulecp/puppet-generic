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

  if $lsbdistcodename == 'squeeze' {
    # Shared Trac configuration
    file { "/etc/trac/trac.ini":
      content => template("gen_trac/trac.ini"),
      owner   => "root",
      group   => "root",
      mode    => 644,
      require => Package["trac"],
    }
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

# Class: gen_trac::git
#
# Actions: Make sure that trac can talk to git
#
class gen_trac::git {
  package { 'trac-git':
    ensure => latest;
  }
}

# Define: gen_trac::environment
#
# Actions: Setup a Trac environment for a project
#
# Parameters:
#  group: The group which should have access to this Trac instance, mostly for writing and changing files
#  path: A specific path to use. Defaults to '/srv/trac/$name'.
#  svnrepo: The subversion repository to use for this. Defaults to false, which means 'don't use a svn repo'.
#  gitrepo: Like svnrepo, but for git.
#
define gen_trac::environment($group, $path="/srv/trac/${name}", $svnrepo=false, $gitrepo=false) {
  include gen_trac

  if $path {
    $tracdir = $path
  } else {
    $tracdir = "/srv/trac/$name"
  }

  if $svnrepo {
    $repostring = "svn ${svnrepo}"
  } elsif $gitrepo {
    include gen_trac::git
    $repostring = "git ${gitrepo}"
  } else {
    fail('Either a svnrepo or a gitrepo need to be set.')
  }

  # Create the Trac environment
  exec { "create-trac-${name}":
    command   => "/usr/bin/trac-admin ${tracdir} initenv ${name} sqlite:db/trac.db ${repostring}",
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
