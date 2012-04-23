# Author: Kumina bv <support@kumina.nl>

# Class: gen_glassfish
#
# Actions:
#  Install glassfish package and java
#
# Depends:
#  gen_puppet
#
class gen_glassfish ($java_version='oracle-java7-jdk'){
  $java_classname = regsubst($java_version,'-', '_','G')
  include "gen_java::${java_classname}"

  package { "glassfish":
    require => Package[$java_version];
  }
}

# Define: gen_glassfish::domain
#
# Actions:
#  Creates a glassfish domain and sets some options
#
# Parameters:
#  portbase
#   The portbase value determines where the port assignment should start. The values for the ports are calculated as follows:
#   Administration port: portbase + 48
#   HTTP listener port: portbase + 80
#   HTTPS listener port: portbase + 81
#   JMS port: portbase + 76
#   IIOP listener port: portbase + 37
#   Secure IIOP listener port: portbase + 38
#   Secure IIOP with mutual authentication port: portbase + 39
#   JMX port: portbase + 86
#   JPDA debugger port: portbase + 9
#   Felix shell service port for OSGi module management: portbase + 66
#
#  ensure
#   What the domain should be, needed for the service.. should be running or stopped
#   There is some discussion as to what absent should do (because the domain could be on a shared storage medium).
#
# Depends:
#  gen_puppet
#  gen_glassfish
#
define gen_glassfish::domain ($portbase, $ensure="running"){

  if $ensure != "absent" {
    exec { "Create glassfish domain ${name}":
      command => "/opt/glassfish/bin/asadmin create-domain --nopassword=true --portbase ${portbase} ${name} ",
      creates => "/opt/glassfish/domains/${name}",
      user    => 'glassfish',
      group   => 'glassfish',
      require => Package['glassfish'];
      }

    service { "glassfish-${name}":
      ensure  => $ensure ? {
        "stopped" => stopped,
        "running" => running,
        default   => "",
      },
      hasrestart => true,
      require => File["/etc/init.d/glassfish-${name}"];
    }
  } else {
    file { "/opt/glassfish/domains/${name}":
      ensure  => absent,
      recurse => true,
      force   => true;
    }
  }

  file { "/etc/init.d/glassfish-${name}":
    ensure  => $ensure ? {
      "absent" => absent,
      default => present,
    },
    mode    => 755,
    content => template('gen_glassfish/init'),
    require => Exec["Create glassfish domain ${name}"];
  }
}
