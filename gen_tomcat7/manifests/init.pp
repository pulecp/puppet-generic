# Author: Kumina bv <support@kumina.nl>

# Class: gen_tomcat7
#
# Actions:
#  Setup Tomcat 7 in /srv/tomcat, including default users and the manager app.
#  This only allows a single Tomcat instance on a server. The package conflicts
#  with Tomcat 6, so we make sure it's purged.
#
# Parameters:
#  catalina_base
#    The base directory for this Tomcat instance
#  ajp13_connector_port
#    The port to setup for ajp13 connections.
#  ajp13_maxclients
#    The MaxClients setting for Tomcat's AJP port. Does not affect HTTP. Defaults to 200.
#  http_connector_port
#    The port to setup for HTTP connections directly to the Tomcat.
#  java_home
#    The JAVA_HOME variable, place where Java lives.
#  java_opts
#    The JVM options to add to the jvm invocation.
#  jvm_max_mem
#    Maximum memory to allow the JVM to use.
#  jvm_permgen_mem
#    Set the PermGen size for the JVM.
#  tomcat_tag
#    The tag used for exporting the Tomcat users in tomcat-users.xml
#  max_open_files
#    Max. allowed open files (ulimit -n)
#
# Depends:
#  gen_puppet
#  gen_base::openjdk-7-jre
#  gen_tomcat7::manager
#
class gen_tomcat7($catalina_base="/srv/tomcat", $ajp13_connector_port="8009", $http_connector_port="8080",
                  $java_home=false, $java_opts="", $jvm_max_mem=false, $jvm_permgen_mem=false,
                  $tomcat_tag="tomcat_${environment}_${custenv}",$ajp13_maxclients='200', $max_open_files=false, $autodeploy=false) {
  class { 'gen_tomcat7::manager':
    tomcat_tag => $tomcat_tag;
  }
  include gen_base::openjdk-7-jre

  if ! $java_home {
    case $lsbdistcodename {
      'wheezy':  { $real_java_home = "/usr/lib/jvm/java-7-openjdk-${architecture}" }
      'squeeze': { $real_java_home = '/usr/lib/jvm/java-7-openjdk/' }
    }
  } else {
    $real_java_home = $java_home
  }

  if $max_open_files {
    $real_max_open_files = $max_open_files
  }

  if !$jvm_max_mem {
    $tmp_jvm_mem = $memorysizeinbytes/1024/1024*0.75
    $jvm_mem = sprintf('%.0f',$tmp_jvm_mem)
  } else {
    $jvm_mem = $jvm_max_mem
  }

  if !$jvm_permgen_mem {
    $permgen_mem = "128"
  } else {
    $permgen_mem = $jvm_permgen_mem
  }

  kservice { "tomcat7":
    hasreload => false,
    srequire  => File[$catalina_base],
    require   => Package['tomcat6'];
  }

  package { 'tomcat6':
    ensure => purged,
  }

  # This sets the header and footer for the tomcat-users.xml file.
  concat::add_content {
    "tomcat-users top":
      content => "<?xml version='1.0' encoding='utf-8'?>\n<tomcat-users>",
      order   => 10,
      target  => "${catalina_base}/conf/tomcat-users.xml";
    "tomcat-users bottom":
      content => "</tomcat-users>",
      order   => 20,
      target  => "${catalina_base}/conf/tomcat-users.xml";
  }

  # Create the actual tomcat-users.xml file
  concat { "${catalina_base}/conf/tomcat-users.xml":
    require => File["${catalina_base}/conf"];
  }

  file {
    '/etc/java-7-openjdk/management/jmxremote.password':
      owner   => 'tomcat7',
      mode    => 400,
      require => Package['openjdk-7-jre'];
    $catalina_base:
      ensure  => directory,
      require => Package["tomcat7"];
    ["${catalina_base}/webapps",
     "${catalina_base}/webapps/ROOT",
     "${catalina_base}/lib"]:
      ensure  => directory,
      owner   => "tomcat7",
      group   => "tomcat7",
      mode    => 775,
      require => Package["tomcat7"];
    "${catalina_base}/conf":
      ensure  => link,
      target  => "/etc/tomcat7",
      require => Package["tomcat7"];
    "${catalina_base}/logs":
      ensure  => link,
      target  => "/var/log/tomcat7",
      require => Package["tomcat7"];
    "${catalina_base}/work":
      ensure  => link,
      target  => "/var/cache/tomcat7",
      require => Package["tomcat7"];
    "/etc/default/tomcat7":
      content => template("gen_tomcat7/default"),
      require => [Package["tomcat7"], File['/etc/java-7-openjdk/management/jmxremote.password']],
      notify  => Service["tomcat7"];
    "/etc/tomcat7/server.xml":
      content => template("gen_tomcat7/server.xml"),
      require => Package["tomcat7"];
  }
}

# Class: gen_tomcat7::manager
#
# Actions:
#  The manager app is used to control different contexts within Tomcat. You need one per instance.
#  In addition to this, you need to override the Gen_tomcat7::User["manager"] to set the password.
#
# Depends:
#  gen_puppet
#  gen_tomcat
#
class gen_tomcat7::manager ($tomcat_tag="tomcat_${environment}_${custenv}") {
  package { "tomcat7-admin":
    require => Package['tomcat7'],
    notify  => Exec["remove-tomcatmanagerxml"];
  }

  # This is a workaround for a bug in Augeas' xml lens that causes it to fail
  # on XML <elements/> like this one (<elements></elements> is fine);
  # The "tomcat7-admin" package includes files with this faulty XML tag.
  exec { "remove-tomcatmanagerxml":
    command     => "/bin/rm -f /etc/tomcat7/Catalina/localhost/manager.xml /etc/tomcat7/Catalina/localhost/host-manager.xml",
    refreshonly => true,
    notify      => [File["/etc/tomcat7/Catalina/localhost/manager.xml"],File["/etc/tomcat7/Catalina/localhost/host-manager.xml"]],
    require     => Package["tomcat7-admin"];
  }

  file {
    "/etc/tomcat7/Catalina/localhost/manager.xml":
      content => template("gen_tomcat7/manager.xml"),
      replace => false,
      owner   => "tomcat7",
      group   => "tomcat7",
      mode    => 0664,
      require => Package["tomcat7-admin"],
      notify  => Gen_tomcat7::Context["manager"];
    "/etc/tomcat7/Catalina/localhost/host-manager.xml":
      content => template("gen_tomcat7/host-manager.xml"),
      replace => false,
      owner   => "tomcat7",
      group   => "tomcat7",
      mode    => 0664,
      require => Package["tomcat7-admin"],
      notify  => Gen_tomcat7::Context["host-manager"];
  }

  gen_tomcat7::context {
    "manager":
      war     => "/usr/share/tomcat7-admin/manager",
      require => Package["tomcat7-admin"],
      urlpath => "/manager";
    "host-manager":
      war     => "/usr/share/tomcat7-admin/host-manager",
      require => Package["tomcat7-admin"],
      urlpath => "/host-manager";
  }

  gen_tomcat7::additional_context_setting {
    "manager: antiResourceLocking":
      value => "false";
    "manager: privileged":
      value => "true";
    "host-manager: antiResourceLocking":
      value => "false";
    "host-manager: privileged":
      value => "true";
  }

  gen_tomcat7::valve {
    "manager: org.apache.catalina.valves.RemoteAddrValve":
      allow => '127\.0\.0\.1';
    "host-manager: org.apache.catalina.valves.RemoteAddrValve":
      allow => '127\.0\.0\.1';
  }

  gen_tomcat7::user { "manager":
    tomcat_tag => $tomcat_tag,
    username   => "manager",
    role       => "manager-gui",
    password   => "BOGUS";
  }

  gen_tomcat7::role {
    "manager-gui":
      tomcat_tag => $tomcat_tag,
      role       => "manager-gui";
    "manager-script":
      tomcat_tag => $tomcat_tag,
      role       => "manager-script";
    "manager-jmx":
      tomcat_tag => $tomcat_tag,
      role       => "manager-jmx";
    "manager-status":
      tomcat_tag => $tomcat_tag,
      role       => "manager-status";
  }
}

# Define: gen_tomcat7::context
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
#  gen_tomcat7
#
define gen_tomcat7::context($war, $urlpath, $extra_opts="", $context_xml_content=false, $root_app=false, $tomcat_tag="tomcat_${environment}") {
  file { "/srv/tomcat/conf/Catalina/localhost/${name}.xml":
    content => $context_xml_content ? {
      false   => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Context path=\"${urlpath}\" docBase=\"${war}\">${extra_opts}</Context>",
      default => $context_xml_content
    },
    replace => $context_xml_content ? {
      false   => false,
      default => true
    },
    owner   => "tomcat7",
    group   => "tomcat7",
    mode    => "664",
    require => [Package["tomcat7"], File["/srv/tomcat/conf"]];
  }

  if $context_xml_content == false {
    kaugeas { "Context path and docBase for ${name}":
      file    => "/srv/tomcat/conf/Catalina/localhost/${name}.xml",
      lens    => "Xml.lns",
      changes => ["set Context/#attribute/path '${urlpath}'",
                  "set Context/#attribute/docBase '${war}'"],
      notify  => Service["tomcat7"],
      require => File["/srv/tomcat/conf/Catalina/localhost/${name}.xml"];
    }
  } else {
    notify { "The context_xml_content parameter is deprecated. Please remove asap.":; }
  }

  if $root_app {
    file { "/srv/tomcat/webapps/ROOT/index.jsp":
      content => "<% response.sendRedirect(\"${name}\"); %>",
      require => File["/srv/tomcat/webapps/ROOT"];
    }
  }
}

# Define: gen_tomcat7::additional_context_setting
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
#  gen_tomcat7
#
define gen_tomcat7::additional_context_setting($value, $context = false, $setting_name = false) {
  if $context and $setting_name {
    $real_context = $context
    $real_name = $setting_name
  } else {
    $real_context = regsubst($name, '(.*):.*', '\1')
    $real_name = regsubst($name, '.*: (.*)', '\1')
  }

  kaugeas { "Context setting ${real_name} for ${real_context}":
    file    => "/srv/tomcat/conf/Catalina/localhost/${real_context}.xml",
    lens    => "Xml.lns",
    changes => "set Context/#attribute/${real_name} '${value}'",
    notify  => Service["tomcat7"],
    require => File["/srv/tomcat/conf/Catalina/localhost/${real_context}.xml"];
  }
}

# Define: gen_tomcat7::environment
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
#  gen_tomcat7
#
define gen_tomcat7::environment ($var_type, $value, $context = false, $var_name = false) {
  if $context and $var_name {
    $real_context = $context
    $real_name = $var_name
  } else {
    $real_context = regsubst($name, '(.*):.*', '\1')
    $real_name = regsubst($name, '.*: (.*)', '\1')
  }

  kaugeas { "Context setting ${real_name} for ${real_context}":
    file    => "/srv/tomcat/conf/Catalina/localhost/${real_context}.xml",
    lens    => "Xml.lns",
    changes => ["set Context/Environment[#attribute/name='${real_name}']/#attribute/name '${real_name}'",
                "set Context/Environment[#attribute/name='${real_name}']/#attribute/value '${value}'",
                "set Context/Environment[#attribute/name='${real_name}']/#attribute/type '${var_type}'"],
    notify  => Service["tomcat7"],
    require => File["/srv/tomcat/conf/Catalina/localhost/${real_context}.xml"];
  }
}

# Define: gen_tomcat7::valve
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
#  gen_tomcat7
#
define gen_tomcat7::valve($allow, $context = false, $classname = false) {
  if $context and $classname {
    $real_context = $context
    $real_name = $classname
  } else {
    $real_context = regsubst($name, '(.*):.*', '\1')
    $real_name = regsubst($name, '.*: (.*)', '\1')
  }

  kaugeas { "Context valve ${real_name} for ${real_context}":
    file    => "/srv/tomcat/conf/Catalina/localhost/${real_context}.xml",
    lens    => "Xml.lns",
    changes => ["set Context/Valve[#attribute/className='${real_name}']/#attribute/className '${real_name}'",
                "set Context/Valve[#attribute/className='${real_name}']/#attribute/allow '${allow}'"],
    notify  => Service["tomcat7"],
    require => File["/srv/tomcat/conf/Catalina/localhost/${real_context}.xml"];
  }
}

# Define: gen_tomcat7::datasource
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
#  gen_tomcat7
#
define gen_tomcat7::datasource($username, $password, $url, $context = false, $max_active = "8", $max_idle = "4", $resource = false) {
  if $context and $resource {
    $real_context = $context
    $real_name = $resource
  } else {
    $real_context = regsubst($name, '(.*):.*', '\1')
    $real_name = regsubst($name, '.*: (.*)', '\1')
  }

  kaugeas { "Context datasource resource ${real_name} for ${real_context}":
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
    notify  => Service["tomcat7"],
    require => File["/srv/tomcat/conf/Catalina/localhost/${real_context}.xml"];
  }
}

# Define: gen_tomcat7::user
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
#    The role of this user. The role should be added with gen_tomcat7::role.
#  tomcat_tag
#    The tag to use for the created resource.
#
# Depends:
#  gen_tomcat7
#
define gen_tomcat7::user ($username=$name, $password, $role, $tomcat_tag="tomcat_${environment}_${custenv}") {
  if $username == "manager" and $password=="BOGUS" {
    fail("please override the manager password")
  }
  concat::add_content { "${username} in role ${role}":
    content    => "<user username=\"${username}\" password=\"${password}\" roles=\"${role}\"/>",
    target     => "/srv/tomcat/conf/tomcat-users.xml",
    order      => 15,
    contenttag => "${tomcat_tag}_user",
    require    => [Gen_tomcat7::Role[$role], File["/srv/tomcat/conf"]];
  }
}

# Define: gen_tomcat7::role
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
#  gen_tomcat7
#
define gen_tomcat7::role ($role=$name, $tomcat_tag="tomcat_${environment}_${custenv}") {
  concat::add_content { "role ${role}":
    content    => "<role rolename=\"${role}\"/>",
    target     => "/srv/tomcat/conf/tomcat-users.xml",
    order      => 11,
    contenttag => "${tomcat_tag}_user";
  }
}
