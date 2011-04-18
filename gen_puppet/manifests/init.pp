class gen_puppet {
	kpackage { ["puppet","puppet-common"]:; }
}

class gen_puppet::vim {
	kpackage { "vim-puppet":
		ensure => latest,
	}
}
