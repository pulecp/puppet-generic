# Author: Kumina bv <support@kumina.nl>

# Class: offsitebackup::common
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class offsitebackup::common {
  define backupkey($backupserver, $backuproot=$backup_home, $user, $key, $backupdir=$name) {
    $real_backupdir = "$backuproot/$backupdir"
    $line = "command=\"rdiff-backup --server --restrict ${real_backupdir}\",no-pty,no-port-forwarding,no-agent-forwarding,no-X11-forwarding ssh-rsa $key Backup key for $name"

    line { "add-key-${name}":
      file    => "${backuproot}/.ssh/authorized_keys",
      content => $line,
      require => [User[$user], File["${backuproot}/.ssh"]],
    }
  }

  define backupuser($home=$backup_home, $comment="") {
    user { "$name":
      ensure => present,
      home => $home,
      membership => minimum,
      shell => "/bin/bash",
      comment => $comment,
    }

    file { "$home":
      ensure => directory,
      mode => 750,
      owner => $name,
      group => "backup",
      require => User["$name"],
    }

    file { "$home/.ssh":
      ensure => directory,
      mode => 700,
      owner => $name,
      group => "users",
      require => File["$home"],
    }

    file { "$home/.ssh/authorized_keys":
      ensure => file,
      mode => 644,
      owner => $name,
      group => "users",
      require => File["$home/.ssh"],
    }
  }
}

# Class: offsitebackup::client
#
# Actions:
#  Undocumented
#
# Parameters:
#  splay: number of second to use as max splay. Defaults to 28800 (8 hours).
#
# Depends:
#  Undocumented
#  gen_puppet
#
class offsitebackup::client($backup_server, $backup_home="/backup/${environment}", $backup_user=$environment, $backup_remove_older_than="30B", $splay=28800, $listfile='/tmp/backuplist') {
  include gen_base::backup-scripts
  include offsitebackup::client::package

  Sshkey <<| title == $backup_server |>>

  @@offsitebackup::common::backupkey { "$fqdn":
    backupserver => $backup_server,
    backuproot => $backup_home,
    user => $backup_user,
    key => $backupsshkey,
    require => Package["offsite-backup"],
  }

  $backup_rm_older_than = $backup_remove_older_than ? {
    undef => "30B",
    default => $backup_remove_older_than,
  }

  file { "/etc/backup/offsite-backup.conf":
    content => template("offsitebackup/client/offsite-backup.conf"),
    require => Package["offsite-backup"];
  }

  file { "/etc/backup/prepare.d/dpkg-list":
    ensure => symlink,
    target => "/usr/share/offsite-backup/prepare/dpkg-list",
    require => Package["offsite-backup"];
  }

  file { "/etc/backup/prepare.d/filesystems":
    ensure => symlink,
    target => "/usr/share/offsite-backup/prepare/filesystems",
    require => Package["offsite-backup"];
  }
}

class offsitebackup::client::package {
  package { ["offsite-backup"]:
    ensure => latest;
  }
}

# Define: offsitebackup::extraclient
#
# Actions:
#  Configures an extra backup client, e.g. to backup a certain folder elsewhere
#
# Parameters:
#  splay: number of second to use as max splay. Defaults to 28800 (8 hours).
#  confprefix: prefix config files in /etc/backup with this (defaults to "${name}_")
#  backupdir: directory on the server; defaults to "${fqdn}_${name}"
#  sshpubkey: ssh public key to use (string)
#  sshprivkey: ssh private key to use (file)
#  prepare: directory with prepare scripts (optional)
#  prepare_conf: directory with configuration for the prepare scripts (optional)
#  finish: directory with finish scripts (optional)
#  finish_conf: directory with configuration for the finish scripts (optional)
#  includes: a list of patterns to include
#  excludes: a list of patterns to exclude (optional)
#
# Depends:
#  Undocumented
#  gen_puppet
#
define offsitebackup::extraclient($backup_server, $backup_home="/backup/${environment}", $backup_user=$environment, $backup_remove_older_than="30B", $splay=28800, $confprefix="${name}_", $sshpubkey, $sshprivkey, $backupdir="${fqdn}_${name}", $prepare="/dev/null", $prepare_conf="/dev/null", $finish="/dev/null", $finish_conf="/dev/null", $includes, $excludes='', $listfile="/tmp/backuplist_${name}") {
  include gen_base::backup-scripts
  include offsitebackup::client::package

  Sshkey <<| title == $backup_server |>>

  @@offsitebackup::common::backupkey { "${backupdir}_${fqdn}":
    backupdir => $backupdir,
    backupserver => $backup_server,
    backuproot => $backup_home,
    user => $backup_user,
    key => $sshpubkey,
    require => Package["offsite-backup"],
  }

  $backup_rm_older_than = $backup_remove_older_than ? {
    undef => "30B",
    default => $backup_remove_older_than,
  }

  file {
    "/etc/backup/${confprefix}includes":
      content => template("offsitebackup/client/includes"),
      require => Package["offsite-backup"];
    "/etc/backup/${confprefix}excludes":
      content => template("offsitebackup/client/excludes"),
      require => Package["offsite-backup"];
    "/etc/backup/${confprefix}offsite-backup.conf":
      content => template("offsitebackup/client/offsite-backup.conf"),
      require => Package["offsite-backup"];
    "/etc/backup/${confprefix}ssh_key.pub":
      content => $sshpubkey,
      require => Package["offsite-backup"];
    "/etc/backup/${confprefix}ssh_key":
      mode    => 0400,
      source  => $sshprivkey,
      require => Package["offsite-backup"];
  }
}

# Class: offsitebackup::server
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class offsitebackup::server {
  Offsitebackup::Common::Backupkey <<| backupserver == $fqdn |>>

  package { ["rdiff-backup", "python-pylibacl", "python-pyxattr"]:
    ensure => installed,
  }
}
