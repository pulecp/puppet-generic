class gen_gitlistchanges {
    kpackage { "gitlistchanges":
        ensure => latest;
    }

    @kfile {
        "/etc/gitlistchanges.conf":
            content => "includedir:/etc/gitlistchanges.conf.d\n";
        "/etc/gitlistchanges.conf.d":
            ensure => directory;
    }

    define repoconfig ($to, $repo=false, $from=false, $branch=false, $since=false, $forcustomer=false) {
	$the_repo = $name ? {
		false => $repo,
		default => $name,
	}
	$the_repo_safe = regsubst($the_repo, '/', '_', "G")

        realize Kfile["/etc/gitlistchanges.conf", "/etc/gitlistchanges.conf.d"]

        kfile { "/etc/gitlistchanges.conf.d/${the_repo_safe}-${to}":
            content => template("gen_gitlistchanges/repoconfig.erb");
        }
    }
}
