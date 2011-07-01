# Author: Kumina bv <support@kumina.nl>

# Class: gen_git
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
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

# Class: gen_git::gitg
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_git::gitg {
	if $lsbmajdistrelease >= 6 { # Available from squeeze on
		kpackage { "gitg":
			ensure => latest;
		}
	}
}

# Class: gen_git::listchanges
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_git::listchanges {
	kpackage { "gitlistchanges":
		ensure => latest;
	}

	@kfile {
		"/etc/gitlistchanges.conf":
			content => "includedir:/etc/gitlistchanges.conf.d\n";
		"/etc/gitlistchanges.conf.d":
			ensure  => directory,
			source  => "gen_git/listchanges/gitlistchanges.conf.d",
			purge   => true,
			recurse => true;
	}

	define repoconfig ($to, $repo=false, $from=false, $branch=false, $since=false, $forcustomer=false) {
		$the_repo = $name ? {
			false   => $repo,
			default => $name,
		}
		$the_repo_safe = regsubst($the_repo, '/', '_', "G")

		realize Kfile["/etc/gitlistchanges.conf", "/etc/gitlistchanges.conf.d"]

		kfile { "/etc/gitlistchanges.conf.d/${the_repo_safe}-${to}":
			content => template("gen_git/listchanges/repoconfig.erb");
		}
	}
}
