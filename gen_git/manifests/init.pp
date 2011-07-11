# Author: Kumina bv <support@kumina.nl>

# Class: gen_git
#
# Actions:
#	Install git
#
# Depends:
#	gen_puppet
#
class gen_git {
	if $lsbmajdistrelease >= 6 { #squeeze or newer
		$git_pkg = "git"
	} else { #lenny or older
		$git_pkg = "git-core"
	}

	kpackage { "${git_pkg}":
		ensure => latest;
	}
}

# Class: gen_git::listchanges
#
# Actions:
#	Install gitlistchanges
#
# Depends:
#	gen_puppet
#
class gen_git::listchanges::install {
	kpackage { "gitlistchanges":
		ensure => latest;
	}

	kfile {
		"/etc/gitlistchanges.conf":
			content => "includedir:/etc/gitlistchanges.conf.d\n";
		"/etc/gitlistchanges.conf.d":
			ensure  => directory,
			purge   => true,
			recurse => true;
	}
}

# Define: gen_git::repo
#
# Actions:
#	Set up git repository
#
# Parameters:
#	name
#		The directory where to create the repository.
#		Needs to be a kfile already.
#	branch
#		The remote branch of the origin. Defaults to
#		"master".
#	origin
#		Add an origin to the repository. This does
#		not clone the remote repository.
#
# Depends:
#	gen_git
#	gen_puppet
#
define gen_git::repo ($branch = "master", $origin = false) {
	include gen_git

	# I thought about adding an option to automatically clone a remote
	# repository, but that won't work very often since you'd have to
	# give puppet access to your ssh secret key. You don't want that.

	exec { "/usr/bin/git init -q --shared=group ${name}":
		creates => "${name}/.git",
		require => $name,
	}

	if $origin {
		exec { "/usr/bin/git remote add -m ${branch} origin ${origin}":
			unless => "/usr/bin/git config --get remote.origin.url | grep -q '${origin}'",
		}
	}
}

# Define: gen_git::repoconfig
#
# Actions:
#	Set up config for gitlistchanges
#
# Parameters:
#	to
#		Mail address the changes will be mailed to
#	repo
#		Path to the repo, defaults to the name
#	from
#		Sender address, not set by default
#	branch
#		Branch to report on, not set by default
#	since
#		Report from this moment till now, not set by default
#	condense
#		Leave out committer names and detailed info, not set by default
#
# Depends:
#	gen_git::listchanges::install
#	gen_puppet
#
define gen_git::listchanges ($to, $repo=false, $from=false, $branch=false, $since=false, $condense=false) {
	include gen_git::listchanges::install

	$the_repo = $name ? {
		false   => $repo,
		default => $name,
	}
	$the_repo_safe = regsubst($the_repo, '/', '_', "G")

	kfile { "/etc/gitlistchanges.conf.d/${the_repo_safe}-${to}":
		content => template("gen_git/listchanges/repoconfig.erb");
	}
}
