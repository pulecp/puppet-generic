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

define kbp_puppet::set_config ($var, $value, $configfile = '/etc/puppet/puppet.conf', $section = 'main', $order = false) {
	# If order is set, don't use section
	if $order {
		$real_order = $order
	} else {
		# Based on section, set order
		$real_order = $section ? {
			'main'   => "15",
			'agent'  => "25",
			'master' => "35",
			'queue'  => "45",
			default  => fail("No order given and no known section given."),
		}
	}

	gen_puppet::concat::add_content { $name:
		target  => $configfile,
		content => "${var} = ${value}",
		order   => $real_order,
	}
}
