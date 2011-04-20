class gen_gitlistchanges {
    kpackage { "gitlistchanges":
        ensure => latest;
    }

    define repoconfig($repo, $to, $from=false, $branch=false, $since=false, $forcustomer=false) { 
        kfile {
            "/etc/gitlistchanges.conf":
                content => "include: /etc/gitlistchanges.conf.d\n";
            "/etc/gitlistchanges.conf.d":
                ensure => directory;
            "/etc/gitlistchanges.conf.d/${name}-${to}":
                content => template("gen_listchanges/repoconfig.erb");
        }
    }
}
