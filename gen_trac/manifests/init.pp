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

# Class: gen_trac::svn
#
# Actions: Make sure that trac can talk to subversion
#
class gen_trac::svn {
  include gen_base::python_subversion
}

# Class: gen_trac::datefield
#
# Actions: Install the datefield plugin globally for Trac.
#
class gen_trac::datefield {
  package { 'trac-datefieldplugin':
    ensure => latest;
  }
}

# Class: gen_trac::xmlrpc
#
# Actions: Install the xmlrpc plugin globally for Trac.
#
class gen_trac::xmlrpc {
  package { 'trac-xmlrpc':
    ensure => latest;
  }
}

# Class: gen_trac::tags
#
# Actions: Install the tags plugin globally for Trac.
#
class gen_trac::tags {
  package { 'trac-tags':
    ensure => latest;
  }
}

# Class: gen_trac::accountmanager
#
# Actions: Install the accountmanager plugin globally for Trac.
#
class gen_trac::accountmanager {
  package { 'trac-accountmanager':
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
#  dbtype: The database to use. Defaults to 'sqlite', but 'postgres' can be used as well.
#
define gen_trac::environment($group, $path="/srv/trac/${name}", $svnrepo=false, $gitrepo=false, $dbtype='sqlite', $dbuser=$name, $dbpassword=false, $dbhost='localhost', $dbname=$name) {
  include gen_trac

  if $path {
    $tracdir = $path
  } else {
    $tracdir = "/srv/trac/${name}"
  }

  if $svnrepo {
    include gen_trac::svn
    $repotype = 'svn'
    $repopath = $svnrepo
  } elsif $gitrepo {
    include gen_trac::git
    $repotype = 'git'
    $repopath = $gitrepo
  } else {
    fail('Either a svnrepo or a gitrepo need to be set.')
  }

  if $dbtype == 'postgres' {
    if ! $dbpassword {
      fail("Dbpassword is required.")
    }

    $dsn = "postgres://${dbuser}:${dbpassword}@${dbhost}/${dbname}"
  } elsif $dbtype == 'sqlite' {
    $dsn = 'sqlite:db/trac.db'
  } else {
    fail("Dbtype should be either sqlite or postgres, not ${dbtype}")
  }

  # Create the Trac environment
  exec { "create-trac-${name}":
    command   => "/usr/bin/trac-admin ${tracdir} initenv ${name} sqlite:db/trac.db ${repotype} ${repopath}",
    logoutput => false,
    creates   => "${tracdir}/VERSION",
    require   => Package["trac"],
  }

  # The config file
  concat { "${tracdir}/conf/trac.ini":
    owner   => "www-data",
    group   => $group,
    mode    => 0664,
    require => Exec["create-trac-${name}"];
  }

  concat::add_content {
    "base trac header for ${name}":
      target  => "${tracdir}/conf/trac.ini",
      order   => 10,
      content => template('gen_trac/trac.ini.base');
    "base trac settings for ${name}":
      target  => "${tracdir}/conf/trac.ini",
      order   => 20,
      content => template('gen_trac/trac.ini.base');
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
    ["${tracdir}/db/trac.db","${tracdir}/log/trac.log"]:
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

# Define: gen_trac::accountmanager_setup
#
# Actions: Setup the accountmanger plugin for a trac instance
#
define gen_trac::accountmanager_setup ($access_file, $path="/srv/trac/${name}") {
  include gen_trac::accountmanager

  concat::add_content { "accountmanger_settings_for_${name}":
    target  => "${path}/conf/trac.ini",
    order   => 11,
    content => template('gen_trac/trac.ini.accountmanager');
  }
}
