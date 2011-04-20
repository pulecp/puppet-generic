class gen_puppet {
	kpackage { ["puppet","puppet-common"]:; }
}

class gen_puppet::puppet_conf {
	include gen_puppet::concat

	# Setup the default config file
	concat { '/etc/puppet/puppet.conf':
		owner => 'root',
		group => 'root',
		mode  => '0640',
	}


}
