# Author: Kumina bv <support@kumina.nl>

# Class: gen_subversion::server
#
# Actions:
#  Setup default stuff for a server hosting subversion repositories.
#
class gen_subversion::server {
  include gen_subversion::client

  file { "/srv/svn":
    owner  => "root",
    group  => "root",
    mode   => 755,
    ensure => directory,
  }
}

# Class: gen_subversion::client
#
# Actions: Install the subversion package.
#
class gen_subversion::client {
  package { "subversion":
    ensure => latest;
  }
}

# Define: gen_subversion::repo
#
# Actions: Setup a subversion repository.
#
define gen_subversion::repo($group, $svndir="/srv/svn/${name}", $mode="2755", $svnowner='root') {
  include gen_subversion::server

  # create the repo
  exec { "create-svn-${name}":
    command => "/usr/bin/svnadmin create --fs-type fsfs ${svndir}",
    creates => $svndir,
    require => [File['/srv/svn'],Package['subversion']];
  }

  # Make sure the files and directories have the correct group
  file { $svndir:
    require => Exec["create-svn-${name}"],
    mode    => $mode,
    owner   => $svnowner,
    group   => $group,
    recurse => false,
  }

  # Grant write permissions to the group where needed
  file {
    ["${svndir}/conf","${svndir}/db","${svndir}/locks"]:
      mode    => 2775,
      owner   => $svnowner,
      group   => $group,
      recurse => false;
    ["${svndir}/db/current","${svndir}/db/revprops/0","${svndir}/db/revs/0","${svndir}/db/uuid","${svndir}/db/write-lock","${svndir}/hooks/post-commit.tmpl",
     "${svndir}/hooks/post-lock.tmpl","${svndir}/hooks/post-revprop-change.tmpl","${svndir}/hooks/post-unlock.tmpl","${svndir}/hooks/pre-commit.tmpl","${svndir}/hooks/pre-lock.tmpl",
     "${svndir}/hooks/pre-revprop-change.tmpl","${svndir}/hooks/pre-unlock.tmpl","${svndir}/hooks/start-commit.tmpl","${svndir}/locks/db-logs.lock","${svndir}/locks/db.lock",
     "${svndir}/db/txn-current-lock","${svndir}/db/txn-current"]:
      mode    => 664,
      owner   => $svnowner,
      group   => $group;
    ["${svndir}/db/revprops","${svndir}/db/revs","${svndir}/db/transactions","${svndir}/dav","${svndir}/db/txn-protorevs"]:
      mode    => 2775,
      owner   => $svnowner,
      group   => $group;
    "${svndir}/hooks":
      mode    => 775,
      owner   => $svnowner,
      group   => $group,
      recurse => false;
  }
}
