class gen_puppet {
# TODO For now, let's make this step optional
#	include gen_puppet::puppet_conf

	kpackage { ["puppet","puppet-common"]:; }
}

class gen_puppet::puppet_conf {
	include gen_puppet::concat

	# Setup the default config file
	concat { '/etc/puppet/puppet.conf':
		owner   => 'root',
		group   => 'root',
		mode    => '0640',
		require => Kpackage["puppet-common"],
	}

	# Already define all the sections
	gen_puppet::concat::add_content {
		"main section":
			target  => '/etc/puppet/puppet.conf',
			content => "[main]\n",
			order   => '10';
		"agent section":
			target  => '/etc/puppet/puppet.conf',
			content => "\n[agent]\n",
			order   => '20';
		"master section":
			target  => '/etc/puppet/puppet.conf',
			content => "\n[master]\n",
			order   => '30';
		"queue section":
			target  => '/etc/puppet/puppet.conf',
			content => "\n[queue]\n",
			order   => '40';
	}
}

define gen_puppet::set_config ($value, $configfile = '/etc/puppet/puppet.conf', $section = 'main', $order = false, $var = false) {
	# If no variable name is set, use the name
	if $var {
		$real_var = $var
	} else {
		$real_var = $name
	}

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
		content => "${real_var} = ${value}",
		order   => $real_order,
	}
}
