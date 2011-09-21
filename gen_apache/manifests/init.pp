# Author: Kumina bv <support@kumina.nl>

# Class: apache
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_apache {
	include gen_base::libapr1

	kservice { "apache2":; }

	exec { "force-reload-apache2":
		command     => "/etc/init.d/apache2 force-reload",
		refreshonly => true,
		require     => Package["apache2"];
	}

	kfile {
		"/etc/apache2/httpd.conf":
			content => template("gen_apache/httpd.conf"),
			require => Package["apache2"];
		"/etc/apache2/vhost-additions":
			ensure  => directory,
			require => Package["apache2"];
		"/etc/apache2/sites-available/default":
			ensure  => absent,
			require => Package["apache2"];
		"/etc/apache2/sites-available/default-ssl":
			ensure  => absent,
			require => Package["apache2"];
	}

	concat { "/etc/apache2/ports.conf":
			require => Package["apache2"],
			notify  => Exec["reload-apache2"];
	}
}

class gen_apache::headers {
	apache::module { "headers":; }
}

define gen_apache::site($ensure="present", $address="*", $serveralias=false, $scriptalias=false, $documentroot="/var/www", $tomcatinstance="",
		$proxy_port="", $djangoproject="", $djangoprojectpath="", $ssl_ipaddress="*", $ssl_ip6address="", $ssl=false,
		$make_default=false) {
	$full_name = regsubst($name,'^([^_]*)$','\1_80')
	$real_name = regsubst($full_name,'^(.*)_(.*)$','\1')
	$port      = regsubst($full_name,'^(.*)_(.*)$','\2')
	$template  = $ssl ? {
		false => "gen_apache/vhost-additions/basic",
		true  => "gen_apache/vhost-additions/basic_ssl",
	}

	kfile {
		"/etc/apache2/sites-available/${full_name}":
			ensure  => $ensure,
			content => template("gen_apache/available_site"),
			require => Package["apache2"],
			notify  => Exec["reload-apache2"];
		"/etc/apache2/vhost-additions/${full_name}":
			ensure  => $ensure ? {
				present => directory,
				absent  => absent,
			};
		"/etc/apache2/vhost-additions/${full_name}/${full_name}":
			ensure  => $ensure,
			content => template($template),
			require => Package["apache2"],
			notify  => Exec["reload-apache2"];
	}

	case $ensure {
		"present": {
			if $real_name == "default" or $real_name == "default_ssl" {
				kfile { "/etc/apache2/sites-enabled/000_${full_name}":
					ensure => link,
					target => "/etc/apache2/sites-available/${full_name}";
				}
			} else {
				exec { "/usr/sbin/a2ensite ${full_name}":
					unless  => "/bin/sh -c '[ -L /etc/apache2/sites-enabled/${full_name} ] && [ /etc/apache2/sites-enabled/${full_name} -ef /etc/apache2/sites-available/${full_name} ]'",
					require => [Package["apache2"], File["/etc/apache2/sites-available/${full_name}"]],
					notify  => Exec["reload-apache2"];
				}
			}

			if !defined(Concat::Add_content["Listen ${port}"]) {
				concat::add_content { "Listen ${port}":
					target => "/etc/apache2/ports.conf";
				}
			}

			if $make_default {
				gen_apache::forward_vhost { "default":
					forward      => "http://${name}";
				}
			}
		}
		"absent": {
			exec { "/usr/sbin/a2dissite ${full_name}":
				onlyif => "/bin/sh -c '[ -L /etc/apache2/sites-enabled/${full_name} ] && [ /etc/apache2/sites-enabled/${full_name} -ef /etc/apache2/sites-available/${full_name} ]'",
				notify => Exec["reload-apache2"];
			}
		}
	}
}

define gen_apache::module($ensure="present") {
	case $ensure {
		"present": {
			exec { "/usr/sbin/a2enmod ${name}":
				unless  => "/bin/sh -c '[ -L /etc/apache2/mods-enabled/${name}.load ] && [ /etc/apache2/mods-enabled/${name}.load -ef /etc/apache2/mods-available/${name}.load ]'",
				require => Package["apache2"],
				notify  => Exec["force-reload-apache2"];
			}
		}
		"absent": {
			exec { "/usr/sbin/a2dismod ${name}":
				onlyif  => "/bin/sh -c '[ -L /etc/apache2/mods-enabled/${name}.load ] && [ /etc/apache2/mods-enabled/${name}.load -ef /etc/apache2/mods-available/${name}.load ]'",
				require => Package["apache2"],
				notify  => Exec["force-reload-apache2"];
			}
		}
	}
}

define gen_apache::forward_vhost($ensure="present", $port=80, $forward, $serveralias=false, $documentroot="/var/www/") {
	$full_name = "${name}_${port}"

	gen_apache::site { $full_name:
		ensure       => $ensure,
		serveralias  => $serveralias,
		documentroot => $documentroot;
	}

	gen_apache::redirect { $full_name:
		site         => $name,
		substitution => $forward,
		usecond      => false;
	}
}

define gen_apache::redirect($site=$fqdn, $port=80, $usecond=true, $condpattern=false, $teststring="%{HTTP_HOST}", $pattern="^/*", $substitution, $flags="R=301") {
	if $rewritecond and !$condpattern {
		fail { "A condpattern must be supplied if rewritecond is set to true (gen_apache::redirect ${name}).":; }
	}

	$full_site = "${site}_${port}"

	if !defined(Gen_apache::Rewrite_on[$full_site]) {
		gen_apache::rewrite_on { $full_site:; }
	}

	concat::add_content { $name:
		content => template("gen_apache/vhost-additions/redirect"),
		target  => "/etc/apache2/vhost-additions/${full_site}/redirects";
	}
}

define gen_apache::rewrite_on {
	concat { "/etc/apache2/vhost-additions/${name}/redirects":
		notify => Exec["reload-apache2"];
	}

	concat::add_content { "000_Enable rewrite engine for ${name}":
		content => "RewriteEngine on\n",
		target  => "/etc/apache2/vhost-additions/${name}/redirects";
	}
}

define gen_apache::vhost_addition($site=$fqdn, $port=80, $content=false, $source=false) {
	$full_site = "${site}_${port}"

	kfile { "/etc/apache2/vhost-additions/${full_site}/${name}":
		content => $content ? {
			false   => undef,
			default => $content,
		},
		source  => $source ? {
			false   => undef,
			default => $source,
		},
		notify  => Exec["reload-apache2"];
	}
}
