# Author: Kumina bv <support@kumina.nl>
# TODO an initscript/command that uses the management interface of tomcat to start/stop/restart/deploy/undeploy webapps see http://tomcat.apache.org/tomcat-6.0-doc/manager-howto.html

# Class: gen_tomcat
#
# Actions:
#  Setup Tomcat 6 in /srv/tomcat, including default users and the manager app.
#  This only allows a single Tomcat instance on a server.
#
# Parameters:
#  catalina_base
#    The base directory for this Tomcat instance
#  ajp13_connector_port
#    The port to setup for ajp13 connections.
#  http_connector_port
#    The port to setup for HTTP connections directly to the Tomcat.
#  java_home
#    The JAVA_HOME variable, place where Java lives.
#  java_opts
#    The JVM options to add to the jvm invocation.
#  jvm_max_mem
#    Maximum memory to allow the JVM to use.
#  tomcat_tag
#    The tag used for exporting the Tomcat users in tomcat-users.xml
#
# Depends:
#  gen_puppet
#  gen_base::openjdk-6-jre
#  gen_tomcat::manager
#
class gen_tomcat ($catalina_base="/srv/tomcat", $ajp13_connector_port="8009", $http_connector_port="8080",
                  $java_home="/usr/lib/jvm/java-6-openjdk/", $java_opts="", $jvm_max_mem=false, $tomcat_tag="tomcat_${environment}") {
  include gen_tomcat::manager
  include gen_base::openjdk-6-jre

  if !$jvm_max_mem {
    $tmp_jvm_mem = $memorysizeinbytes/1024/1024*0.75
    $jvm_mem = sprintf('%.0f',$tmp_jvm_mem)
  } else {
    $jvm_mem = $jvm_max_mem
  }

  kservice { "tomcat6":
    hasreload => false,
    require   => Kfile["/srv/tomcat"];
  }

  # This sets the header and footer for the tomcat-users.xml file.
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

  # Create the actual tomcat-users.xml file
  concat { "/srv/tomcat/conf/tomcat-users.xml":
    require => Kfile["/srv/tomcat/conf"];
  }

  kfile {
    "/srv/tomcat":
      ensure => directory;
    ["/srv/tomcat/webapps",
     "/srv/tomcat/webapps/ROOT",
     "/srv/tomcat/lib"]:
      ensure => directory,
      owner  => "tomcat6",
      require => Kpackage["tomcat6"];
    "/srv/tomcat/conf":
      ensure => link,
      target => "/etc/tomcat6",
      require => Kpackage["tomcat6"];
    "/srv/tomcat/logs":
      ensure => link,
      target => "/var/log/tomcat6",
      require => Kpackage["tomcat6"];
    "/srv/tomcat/work":
      ensure => link,
      target => "/var/cache/tomcat6",
      require => Kpackage["tomcat6"];
    "/etc/default/tomcat6":
      content => template("gen_tomcat/default"),
      require => Kpackage["tomcat6"],
      notify  => Service["tomcat6"];
    "/etc/tomcat6/server.xml":
      content => template("gen_tomcat/server.xml"),
      require => Kpackage["tomcat6"];
  }
}

# Class: gen_tomcat::manager
#
# Actions:
#  The manager app is used to control different contexts within Tomcat. You need one per instance.
#  In addition to this, you need to override the Gen_tomcat::User["manager"] to set the password.
#
# Depends:
#  gen_puppet
#  gen_tomcat
#
class gen_tomcat::manager ($tomcat_tag="tomcat_${environment}") {
  kpackage { "tomcat6-admin":; }

  gen_tomcat::context {
    "manager":
      war     => "/usr/share/tomcat6-admin/manager",
      require => Package["tomcat6-admin"],
      urlpath => "/manager";
    "host-manager":
      war     => "/usr/share/tomcat6-admin/host-manager",
      require => Package["tomcat6-admin"],
      urlpath => "/host-manager";
  }

  gen_tomcat::additional_context_setting {
    "manager: antiResourceLocking":
      value => "false";
    "manager: privileged":
      value => "true";
    "host-manager: antiResourceLocking":
      value => "false";
    "host-manager: privileged":
      value => "true";
  }

  gen_tomcat::valve {
    "manager: org.apache.catalina.valves.RemoteHostValve":
      allow => "localhost,127.0.0.1";
    "host-manager: org.apache.catalina.valves.RemoteHostValve":
      allow => "localhost,127.0.0.1";
  }

  gen_tomcat::user { "manager":
    tomcat_tag => $tomcat_tag,
    username   => "manager",
    role       => "manager",
    password   => "BOGUS";
  }

  gen_tomcat::role { "manager":
    tomcat_tag => $tomcat_tag,
    role       => "manager";
  }
}

# Define: gen_tomcat::context
#
# Actions:
#  This sets up an (additional) context within this Tomcat instance. Essentially, use this to setup a new application running on Tomcat.
#
# Parameters:
#  war
#    Relative path to the WAR file containing the app.
#  urlpath
#    Location in Tomcat of the application, defaults to /$name.
#  extra_opts
#    Extra context options.
#  context_xml_content
#    If you want to provide the entire context file yourself, use this.
#  root_app
#
# Depends:
#  gen_puppet
#  gen_tomcat
#
define gen_tomcat::context($war, $urlpath, $extra_opts="", $context_xml_content=false, $root_app=false, $tomcat_tag="tomcat_${environment}") {
  kfile { "/srv/tomcat/conf/Catalina/localhost/${name}.xml":
    content => $context_xml_content ? {
      false   => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Context path=\"${urlpath}\" docBase=\"${war}\">${extra_opts}</Context>",
      default => $context_xml_content
    },
    replace => $context_xml_content ? {
      false   => false,
      default => true
    },
    require => [Kpackage["tomcat6"], Kfile["/srv/tomcat/conf"]];
  }

  if $context_xml_content == false {
    kaugeas {
      "Context path and docBase for ${name}":
        file    => "/srv/tomcat/conf/Catalina/localhost/${name}.xml",
        lens    => "Xml.lns",
        changes => ["set Context/#attribute/path '${urlpath}'",
                    "set Context/#attribute/docBase '${war}'"],
        notify  => Service["tomcat6"],
    }
  } else {
    notify { "The context_xml_content parameter is deprecated. Please remove asap.":; }
  }

  if $root_app {
    kfile { "/srv/tomcat/webapps/ROOT/index.jsp":
      content => "<% response.sendRedirect(\"${name}\"); %>",
      require => Kfile["/srv/tomcat/webapps/ROOT"];
    }
  }
}

# Define: gen_tomcat::additional_context_setting
#
# Actions:
#  Setup additional context settings for a specific Tomcat context
#
# Parameters:
#  name
#    Can be setup like "context: setting_name" to not have to have duplicate information
#  context
#    The context this variable should apply to. Optional, can be determined if the name of the resource
#    is properly setup.
#  setting_name
#    The setting to set in the context. Optional, can be determined if the name of the resource is
#    properly setup.
#  value
#    The value the setting should have in the context.
#
# Depends:
#  gen_puppet
#  gen_tomcat::context
#
define gen_tomcat::additional_context_setting($value, $context = false, $setting_name = false) {
  if $context and $setting_name {
    $real_context = $context
    $real_name = $setting_name
  } else {
    $real_context = regsubst($name, '(.*):.*', '\1')
    $real_name = regsubst($name, '.*: (.*)', '\1')
  }

  kaugeas {
    "Context setting ${real_name} for ${real_context}":
      file    => "/srv/tomcat/conf/Catalina/localhost/${real_context}.xml",
      lens    => "Xml.lns",
      changes => "set Context/#attribute/${real_name} '${value}'",
      notify  => Service["tomcat6"],
  }
}

# Define: gen_tomcat::environment
#
# Actions:
#  Setup <Environment/> tags for a specific Tomcat context
#
# Parameters:
#  name
#    Can be setup like "context: var_name" to not have to have double information
#  context
#    The context this variable should apply to. Optional, can be determined if the name of the resource
#    is properly setup.
#  var_name
#    The variable to set in the environment. Optional, can be determined if the name of the resource is
#    properly setup.
#  value
#    The value the variable should have in the environment.
#  var_type
#    The type the value is in. Examples are 'java.lang.String' or 'java.lang.Integer'.
#
# Depends:
#  gen_puppet
#  gen_tomcat::context
#
define gen_tomcat::environment ($var_type, $value, $context = false, $var_name = false) {
  if $context and $var_name {
    $real_context = $context
    $real_name = $var_name
  } else {
    $real_context = regsubst($name, '(.*):.*', '\1')
    $real_name = regsubst($name, '.*: (.*)', '\1')
  }

  kaugeas {
    "Context setting ${real_name} for ${real_context}":
      file    => "/srv/tomcat/conf/Catalina/localhost/${real_context}.xml",
      lens    => "Xml.lns",
      changes => ["set Context/Environment[#attribute/name='${real_name}']/#attribute/name '${real_name}'",
                  "set Context/Environment[#attribute/name='${real_name}']/#attribute/value '${value}'",
                  "set Context/Environment[#attribute/name='${real_name}']/#attribute/type '${var_type}'"],
      notify  => Service["tomcat6"],
  }
}

# Define: gen_tomcat::valve
#
# Actions:
#  Setup <Valve/> tags for a specific Tomcat context
#
# Parameters:
#  name
#    Can be setup like "context: classname" to not have to have double information
#  context
#    The context this variable should apply to. Optional, can be determined if the name of the resource
#    is properly setup.
#  classname
#    The className to set in the context. Optional, can be determined if the name of the resource is
#    properly setup.
#  allow
#    The allow parameter in the Valve class.
#
# Depends:
#  gen_puppet
#  gen_tomcat::context
#
define gen_tomcat::valve($allow, $context = false, $classname = false) {
  if $context and $classname {
    $real_context = $context
    $real_name = $classname
  } else {
    $real_context = regsubst($name, '(.*):.*', '\1')
    $real_name = regsubst($name, '.*: (.*)', '\1')
  }

  kaugeas {
    "Context valve ${real_name} for ${real_context}":
      file    => "/srv/tomcat/conf/Catalina/localhost/${real_context}.xml",
      lens    => "Xml.lns",
      changes => ["set Context/Valve[#attribute/className='${real_name}']/#attribute/className '${real_name}'",
                  "set Context/Valve[#attribute/className='${real_name}']/#attribute/allow '${allow}'"],
      notify  => Service["tomcat6"],
  }
}

# Define: gen_tomcat::datasource
#
# Actions:
#  Setup <Resource/> tags for a specific Tomcat context for a datasource.
#
# Parameters:
#  name
#    Can be setup like "context: resource" to not have to have double information
#  context
#    The context this variable should apply to. Optional, can be determined if the name of the resource
#    is properly setup.
#  resource
#    The name of the resource to set up. Optional, can be determined if the name of the resource is
#    properly setup.
#  username
#    The username to connect as.
#  password
#    The password to connect with.
#  url
#    The DSN to connect to. Something like "jdbc:mysql://mysql/database".
#  max_active
#    Maximum active connections.
#  max_idle
#    Maximum number of idle connections.
#
# Depends:
#  gen_puppet
#  gen_tomcat::context
#
define gen_tomcat::datasource($username, $password, $url, $context = false, $max_active = "8", $max_idle = "4", $resource = false) {
  if $context and $resource {
    $real_context = $context
    $real_name = $resource
  } else {
    $real_context = regsubst($name, '(.*):.*', '\1')
    $real_name = regsubst($name, '.*: (.*)', '\1')
  }

  kaugeas {
    "Context datasource resource ${real_name} for ${real_context}":
      file    => "/srv/tomcat/conf/Catalina/localhost/${real_context}.xml",
      lens    => "Xml.lns",
      changes => ["set Context/Resource[#attribute/name='${real_name}']/#attribute/name '${real_name}'",
                  "set Context/Resource[#attribute/name='${real_name}']/#attribute/auth 'Container'",
                  "set Context/Resource[#attribute/name='${real_name}']/#attribute/type 'javax.sql.DataSource'",
                  "set Context/Resource[#attribute/name='${real_name}']/#attribute/driverClassName 'com.mysql.jdbc.Driver'",
                  "set Context/Resource[#attribute/name='${real_name}']/#attribute/username '${username}'",
                  "set Context/Resource[#attribute/name='${real_name}']/#attribute/password '${password}'",
                  "set Context/Resource[#attribute/name='${real_name}']/#attribute/url '${url}'",
                  "set Context/Resource[#attribute/name='${real_name}']/#attribute/maxActive '${max_active}'",
                  "set Context/Resource[#attribute/name='${real_name}']/#attribute/maxIdle '${max_idle}'"],
      notify  => Service["tomcat6"],
  }
}

# Define: gen_tomcat::user
#
# Actions:
#  This sets up users for the default user management middleware of Tomcat.
#
# Parameters:
#  username
#    Should default to $name.
#  password
#    The password for this user, plain text.
#  role
#    The role of this user. The role should be added with gen_tomcat::role.
#  tomcat_tag
#    The tag to use for the created resource.
#
# Depends:
#  gen_puppet
#  gen_tomcat
#
define gen_tomcat::user ($username=$name, $password, $role, $tomcat_tag="tomcat_${environment}") {
  if $username == "manager" and $password=="BOGUS" {
    fail("please override the manager password")
  }
  concat::add_content { "${username} in role ${role}":
    content    => "<user username=\"${username}\" password=\"${password}\" roles=\"${role}\"/>",
    target     => "/srv/tomcat/conf/tomcat-users.xml",
    order      => 15,
    exported   => true,
    contenttag => "${tomcat_tag}_user",
    require    => [Gen_tomcat::Role[$role], Kfile["/srv/tomcat/conf"]];
  }
}

# Define: gen_tomcat::role
#
# Actions:
#  This sets up roles for the default user management middleware of Tomcat.
#
# Parameters:
#  role
#    Name of the role. Defaults to $name.
#  tomcat_tag
#    Tag to use for the created resource.
#
# Depends:
#  gen_puppet
#  gen_tomcat
#
define gen_tomcat::role ($role=$name, $tomcat_tag="tomcat_${environment}") {
  concat::add_content { "role ${role}":
    content    => "<role rolename=\"${role}\"/>",
    target     => "/srv/tomcat/conf/tomcat-users.xml",
    order      => 11,
    exported   => true,
    contenttag => "${tomcat_tag}_user";
  }
}
