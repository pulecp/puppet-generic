# Author: Kumina bv <support@kumina.nl>

# Class: tomcat::webapps
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class tomcat::webapps {
	package { "tomcat5.5-admin":
		ensure => present,
	}
}

# Class: tomcat::webapps::admin
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class tomcat::webapps::admin {
	include tomcat::webapps

	define setup_for ($ensure = "present", $allow = "*", $path = "/admin") {
		file {
			["/srv/tomcat/$name/conf/Catalina",
			 "/srv/tomcat/$name/conf/Catalina/localhost"]:
				ensure => directory,
				owner => "tomcat55",
				mode => 775;
			"/srv/tomcat/$name/conf/Catalina/localhost/admin.xml":
				ensure => $ensure,
				content => template("tomcat/shared/Catalina/localhost/admin.xml"),
				owner => "tomcat55",
				group => "root",
				mode => 644,
				require => File["/srv/tomcat/$name/conf/Catalina/localhost"];
		}
	}
}

# Class: tomcat::webapps::manager
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class tomcat::webapps::manager {
	include tomcat::webapps

	define setup_for ($ensure = "present", $path = "/manager") {
		file {
			["/srv/tomcat/$name/conf/Catalina",
			 "/srv/tomcat/$name/conf/Catalina/localhost"]:
				ensure => directory,
				owner => "tomcat55",
				mode => 775;
			"/srv/tomcat/$name/conf/Catalina/localhost/manager.xml":
				ensure => $ensure,
				content => template("tomcat/shared/Catalina/localhost/manager.xml"),
				owner => "tomcat55",
				group => "root",
				mode => 644,
				require => File["/srv/tomcat/$name/conf/Catalina/localhost"];
		}
	}
}

# Class: tomcat::webapps::host-manager
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class tomcat::webapps::host-manager {
	include tomcat::webapps

	define setup_for ($ensure = "present", $path = "/host-manager") {
		file {
			["/srv/tomcat/$name/conf/Catalina",
			 "/srv/tomcat/$name/conf/Catalina/localhost"]:
				ensure => directory,
				owner => "tomcat55",
				mode => 775;
			"/srv/tomcat/$name/conf/Catalina/localhost/host-manager.xml":
				ensure => $ensure,
				content => template("tomcat/shared/Catalina/localhost/host-manager.xml"),
				owner => "tomcat55",
				group => "root",
				mode => 644,
				require => File["/srv/tomcat/$name/conf/Catalina/localhost"];
		}
	}
}
