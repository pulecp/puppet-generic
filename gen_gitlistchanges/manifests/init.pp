class gen_gitlistchanges {
    kpackage { "gitlistchanges":
        ensure => latest;
    }

    define repoconfig ($to, $repo=false, $from=false, $branch=false, $since=false, $forcustomer=false) { 
    	$the_repo = $name ? {
		false => $repo,
		default => $name,
	}
	$the_repo_safe = regsubst($the_repo, '/', '_')

        kfile {
            "/etc/gitlistchanges.conf":
                content => "include: /etc/gitlistchanges.conf.d\n";
            "/etc/gitlistchanges.conf.d":
                ensure => directory;
            "/etc/gitlistchanges.conf.d/${the_repo_safe}-${to}":
                content => template("gen_gitlistchanges/repoconfig.erb");
        }
    }
}
