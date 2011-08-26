# Author: Kumina bv <support@kumina.nl>
# TODO an initscript/command that uses the management interface of tomcat to start/stop/restart/deploy/undeploy webapps see http://tomcat.apache.org/tomcat-6.0-doc/manager-howto.html

# Class: gen_tomcat
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_tomcat ($java_home="/usr/lib/jvm/java-6-openjdk/", $catalina_base="/srv/tomcat", $ajp13_connector_port="8009", $http_connector_port="8080") {
	kservice { "tomcat6":
		hasreload => false,
		require   => File["/srv/tomcat"];
	}
	include gen_tomcat::manager
	include gen_base::openjdk-6-jre

	concat::add_content {
		"tomcat-users top":
			content => "<?xml version='1.0' encoding='utf-8'?>\n<tomcat-users>",
			order   => 10,
			target  => "/srv/tomcat/conf/tomcat-users.xml";
		"tomcat-users bottom":
			content => "</tomcat-users>",
			order   => 20,
			target  => "/srv/tomcat/conf/tomcat-users.xml";
	}

	Ekfile <<| tag == "${tomcat_tag}_user" |>>

	concat { "/srv/tomcat/conf/tomcat-users.xml":
		require => File["/srv/tomcat/conf"];
	}

	kfile {
		"/srv/tomcat":
			ensure => directory;
		["/srv/tomcat/webapps",
		 "/srv/tomcat/webapps/ROOT",
		 "/srv/tomcat/lib"]:
			ensure => directory,
			owner  => "tomcat6",
			require => Package["tomcat6"];
		"/srv/tomcat/conf":
			ensure => link,
			target => "/etc/tomcat6",
			require => Package["tomcat6"];
		"/srv/tomcat/logs":
			ensure => link,
			target => "/var/log/tomcat6",
			require => Package["tomcat6"];
		"/srv/tomcat/work":
			ensure => link,
			target => "/var/cache/tomcat6",
			require => Package["tomcat6"];
		"/etc/default/tomcat6":
			content => template("gen_tomcat/default"),
			require => Package["tomcat6"];
		"/etc/tomcat6/server.xml":
			content => template("gen_tomcat/server.xml"),
			require => Package["tomcat6"];
	}
}

define gen_tomcat::context($war=false, $urlpath=false, $extra_opts="", $context_xml_content=false, $root_app=false) {
	kfile { "/srv/tomcat/conf/Catalina/localhost/${name}.xml":
		content => $context_xml_content ? {
			false   => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Context path=\"${urlpath}\" docBase=\"${war}\">${extra_opts}</Context>",
			default => $context_xml_content
		},
		require => [Package["tomcat6"], File["/srv/tomcat/conf"]];
	}

	if $root_app {
		kfile { "/srv/tomcat/webapps/ROOT/index.jsp":
			content => "<% response.sendRedirect(\"${name}\"); %>",
			require => File["/srv/tomcat/webapps/ROOT"];
		}
	}
}

class gen_tomcat::manager {
	kpackage { "tomcat6-admin":; }
	# lockdown the manager
	kfile {
		"/srv/tomcat/conf/Catalina/localhost/manager.xml":
			content => '<?xml version="1.0" encoding="UTF-8"?><Context path="/manager" docBase="/usr/share/tomcat6-admin/manager" antiResourceLocking="false" privileged="true"><Valve className="org.apache.catalina.valves.RemoteHostValve" allow="localhost,127.0.0.1"/></Context>',
			require => [Package["tomcat6-admin"], File["/srv/tomcat/conf"]];
		"/srv/tomcat/conf/Catalina/localhost/host-manager.xml":
			content => '<?xml version="1.0" encoding="UTF-8"?><Context path="/host-manager" docBase="/usr/share/tomcat6-admin/host-manager" antiResourceLocking="false" privileged="true"><Valve className="org.apache.catalina.valves.RemoteHostValve" allow="localhost,127.0.0.1"/></Context>',
			require => [Package["tomcat6-admin"], File["/srv/tomcat/conf"]];
	}

	gen_tomcat::user { "manager":
		username => "manager",
		role     => "manager",
		password => "BOGUS";
	}

	gen_tomcat::role { "manager":
		role => "manager";
	}
}

define gen_tomcat::user ($username, $password, $role, $tomcat_tag="tomcat_${environment}") {
	if $username == "manager" and $password=="BOGUS" {
		fail("please override the managerpassword")
	}
	concat::add_content { "${username} in role ${role}":
		content    => "<user username=\"${username}\" password=\"${password}\" roles=\"${role}\"/>",
		target     => "/srv/tomcat/conf/tomcat-users.xml",
		order      => 15,
		exported   => true,
		contenttag => "${tomcat_tag}_user",
		require    => [Gen_tomcat::Role[$role], File["/srv/tomcat/conf"]];
	}
}

define gen_tomcat::role ($role, $tomcat_tag="tomcat_${environment}") {
	concat::add_content { "role ${role}":
		content    => "<role rolename=\"${role}\"/>",
		target     => "/srv/tomcat/conf/tomcat-users.xml",
		order      => 11,
		exported   => true,
		contenttag => "${tomcat_tag}_user";
	}
}
