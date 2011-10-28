# Class: apache
#
# Actions:
#	Set up ocfs2, the cluster config will not be generated
#
# Depends:
#	gen_puppet
#
class gen_ocfs2 {
	kpackage { "ocfs2console":
		ensure => latest;
	}

	kservice { "o2cb":
		package => "ocfs2-tools",
		require => File["/etc/ocfs2/cluster.conf","/etc/default/o2cb"];
	}

	kfile {
		"/etc/ocfs2":
			ensure  => directory;
		"/etc/default/o2cb":
			content => template("gen_ocfs2/o2cb");
	}
}
