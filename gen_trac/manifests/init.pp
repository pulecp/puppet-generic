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
#  authz_file: Location of the authz file for authz_svn. Defaults to ''.
#  logo_file: Template with the logo. Defaults to false.
#  logo_filename: The name of the file. Need this so we can pass an extension.
#  logo_link: Link for the logo. Defaults to an empty string (no link).
#  logo_alt: Alt text for logo. Defaults to an empty string.
#  trac_name: The title to be used for the site, defaults to the $name.
#  description: The description to use for the site, defaults to the $name.
#
define gen_trac::environment($group, $path="/srv/trac/${name}", $svnrepo=false, $gitrepo=false, $dbtype='sqlite', $dbuser=$name, $dbpassword=false, $dbhost='localhost', $dbname=$name, $authz_file='',
                             $logo_file=false, $logo_filename='', $logo_link='', $logo_alt='', $trac_name=$name, $description=$name) {
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
      content => template('gen_trac/trac.ini.header');
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

  # If a logo file is given, deploy it.
  if $logo_file {
    file { "${tracdir}/htdocs/${logo_filename}":
      content => $logo_file;
    }
  }
}

# Define: gen_trac::accountmanager_setup
#
# Actions: Setup the accountmanger plugin for a trac instance
#
define gen_trac::accountmanager_setup ($access_file, $path="/srv/trac/${name}") {
  include gen_trac::accountmanager

  gen_trac::config { "accountmanager_settings_for_${name}":
    trac    => $name,
    path    => $path,
    section => 'account-manager',
    var     => 'password_file',
    value   => $access_file;
  }

  if $lsbmajdistrelease > 6 {
    gen_trac::config { "accountmanager_setting_passwordStore_for_${name}":
      trac    => $name,
      path    => $path,
      section => 'account-manager',
      var     => 'password_store',
      value   => 'HtPasswdStore';
    }
  } else {
    gen_trac::config { "accountmanager_setting_password_format_for_${name}":
      trac    => $name,
      path    => $path,
      section => 'account-manager',
      var     => 'password_format',
      value   => 'htpasswd';
    }
  }

  gen_trac::components_setup {
    "setting acct_mgr.admin.* for ${name}":
      trac  => $name,
      path  => $path,
      var   => 'acct_mgr.admin.*',
      value => 'enabled';
    "setting acct_mgr.api.* for ${name}":
      trac  => $name,
      path  => $path,
      var   => 'acct_mgr.api.*',
      value => 'enabled';
    "setting acct_mgr.db.sessionstore for ${name}":
      trac  => $name,
      path  => $path,
      var   => 'acct_mgr.db.sessionstore',
      value => 'disabled';
    "setting acct_mgr.htfile.htdigeststore for ${name}":
      trac  => $name,
      path  => $path,
      var   => 'acct_mgr.htfile.htdigeststore',
      value => 'disabled';
    "setting acct_mgr.htfile.htpasswdstore for ${name}":
      trac  => $name,
      path  => $path,
      var   => 'acct_mgr.htfile.htpasswdstore',
      value => 'enabled';
    "setting acct_mgr.http.* for ${name}":
      trac  => $name,
      path  => $path,
      var   => 'acct_mgr.http.*',
      value => 'disabled';
    "setting acct_mgr.notification.* for ${name}":
      trac  => $name,
      path  => $path,
      var   => 'acct_mgr.notification.*',
      value => 'enabled';
    "setting acct_mgr.pwhash.* for ${name}":
      trac  => $name,
      path  => $path,
      var   => 'acct_mgr.pwhash.*',
      value => 'disabled';
    "setting acct_mgr.pwhash.htpasswdhashmethod for ${name}":
      trac  => $name,
      path  => $path,
      var   => 'acct_mgr.pwhash.htpasswdhashmethod',
      value => 'enabled';
    "setting acct_mgr.register.* for ${name}":
      trac  => $name,
      path  => $path,
      var   => 'acct_mgr.register.*',
      value => 'disabled';
    "setting acct_mgr.svnserve.svnservepasswordstore for ${name}":
      trac  => $name,
      path  => $path,
      var   => 'acct_mgr.svnserve.svnservepasswordstore',
      value => 'disabled';
    "setting acct_mgr.web_ui.* for ${name}":
      trac  => $name,
      path  => $path,
      var   => 'acct_mgr.web_ui.*',
      value => 'enabled';
    "setting acct_mgr.web_ui.emailverificationmodule for ${name}":
      trac  => $name,
      path  => $path,
      var   => 'acct_mgr.web_ui.emailverificationmodule',
      value => 'disabled';
  }
}

# Define: gen_trac::datefield_setup
#
# Actions: Setup the datefield plugin for a trac instance
#
define gen_trac::datefield_setup ($path="/srv/trac/${name}", $date_format='mdy', $date_separator='-', $date_first_day='1') {
  include gen_trac::datefield

  gen_trac::components_setup {
    "setting datefield.* for ${name}":
      trac  => $name,
      path  => $path,
      var   => 'datefield.*',
      value => 'enabled';
  }

  gen_trac::config {
    "datefield_format_settings_for_${name}":
      trac    => $name,
      path    => $path,
      section => 'datefield',
      var     => 'format',
      value   => $date_format;
    "datefield_separator_settings_for_${name}":
      trac    => $name,
      path    => $path,
      section => 'datefield',
      var     => 'separator',
      value   => $date_separator;
    "datefield_first_day_settings_for_${name}":
      trac    => $name,
      path    => $path,
      section => 'datefield',
      var     => 'first_day',
      value   => $date_first_day;
  }
}

# Define: gen_trac::tags_setup
#
# Actions: Setup the tags plugin.
#
# More info:
#  - http://trac-hacks.org/wiki/TagsPlugin
#  - http://trac-hacks.org/wiki/TracIni#tags-section
#
define gen_trac::tags_setup ($path="/srv/trac/${name}") {
  include gen_trac::tags

  gen_trac::components_setup { "setting tractags.* for ${name}":
      trac  => $name,
      path  => $path,
      var   => 'tractags.*',
      value => 'enabled';
  }
}

# Define: gen_trac::components_setup
#
# Actions: Add lines to the components setup for a trac instance.
#
# Parameters:
#  name: Something that won't clash, please. Not used for the actual config.
#  trac: The name of the trac environment, should have an associated gen_trac::environment.
#  path: The path to the trac environment, defaults to /srv/trac/$trac (same as gen_trac::environment).
#  var: The variable to set in the components section.
#  value: The value to set the variable to.
#
define gen_trac::components_setup ($trac, $path="/srv/trac/${trac}", $var, $value) {
  gen_trac::config { "trac_components_${name}_for_${trac}":
    trac    => $trac,
    path    => $path,
    section => 'components',
    var     => $var,
    value   => $value,;
  }
}

# Define: gen_trac::config
#
# Actions: Add a config option to the config of a trac instance.
#
# Parameters:
#  name: Something that won't clash.
#  trac: The name of the trac environment, should have an associated gen_trac::environment.
#  path: The path to the trac environment, defaults to /srv/trac/$trac (same as gen_trac::environment).
#  section: The section in which the option must be set.
#  var: The variable to set in the components section.
#  value: The value to set the variable to.
#
define gen_trac::config ($trac, $path="/srv/trac/${trac}", $section, $var, $value) {
  if ! defined(Concat::Add_content["trac_${section}_aaaaaaaaa_for_${trac}"]) {
    concat::add_content { "trac_${section}_aaaaaaaaa_for_${trac}":
      target  => "${path}/conf/trac.ini",
      content => "\n[${section}]";
    }
  }

  concat::add_content { "trac_${section}_${name}_for_${trac}":
    target  => "${path}/conf/trac.ini",
    content => "${var} = ${value}";
  }
}
