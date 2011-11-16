# Author: Kumina bv <support@kumina.nl>

# Define: kfile
#
# Parameters:
#	mode
#		Undocumented
#	content
#		Undocumented
#	recurse
#		Undocumented
#	source
#		Undocumented
#	path
#		Undocumented
#	target
#		Undocumented
#	force
#		Undocumented
#	owner
#		Undocumented
#	purge
#		Undocumented
#	group
#		Undocumented
#	ignore
#		Undocumented
#	ensure
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kfile ($ensure="present", $content=false, $source=false, $path=false, $target=false, $owner="root", $group="root", $mode="0644", $recurse=false, $replace=true, $force=false, $purge=false, $ignore=false) {
	file { "${name}":
		ensure  => $ensure,
		content => $content ? {
			false   => undef,
			default => $content,
		},
		source  => $source ? {
			false   => undef,
			default => "puppet:///modules/${source}",
		},
		path    => $path ? {
			false   => undef,
			default => $path,
		},
		target  => $target ? {
			false   => undef,
			default => $target,
		},
		owner   => $owner,
		group   => $group,
		mode    => $ensure ? {
			directory => $mode ? {
				"0644"   => "0755",
				default =>  $mode,
			},
			default   => $mode,
		},
		recurse => $recurse ? {
			false   => undef,
			default => $recurse,
		},
		replace => $replace,
		force   => $force ? {
			false   => undef,
			default => $force,
		},
		purge   => $purge ? {
			false   => undef,
			default => $purge,
		},
		ignore  => $ignore ? {
			false   => undef,
			default => $ignore,
		};
	}
}
