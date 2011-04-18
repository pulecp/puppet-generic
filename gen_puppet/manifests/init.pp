class gen_puppet {
	gen_apt::preference { ["puppet","puppet-common"]:; }

	kpackage { ["puppet","puppet-common"]:; }
}
