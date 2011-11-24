# Author: Kumina bv <support@kumina.nl>

# Define: gen_linux::kmod
# Copied from:
#  http://projects.puppetlabs.com/projects/1/wiki/Kernel_Modules_Patterns
#
# Actions:
#  Loads or unloads a kernel module
#
# Depends:
#  Undocumented
#  gen_puppet
#
define gen_linux::kmod ($ensure) {
  $modulesfile = $operatingsystem ? { Debian => "/etc/modules", redhat => "/etc/rc.modules" }
  case $operatingsystem {
    redhat: { file { "/etc/rc.modules": ensure => file, mode => 755 } }
  }
  case $ensure {
    present: {
      exec { "insert_module_${name}":
        command => $operatingsystem ? {
          Debian => "/bin/echo '${name}' >> '${modulesfile}'",
          redhat => "/bin/echo '/sbin/modprobe ${name}' >> '${modulesfile}' "
        },
        unless => "/bin/grep -qFx '${name}' '${modulesfile}'"
      }
      exec { "/sbin/modprobe ${name}": unless => "/bin/grep -q '^${name} ' '/proc/modules'" }
    }
    absent: {
      exec { "/sbin/modprobe -r ${name}": onlyif => "/bin/grep -q '^${name} ' '/proc/modules'" }
      exec { "remove_module_${name}":
        command => $operatingsystem ? {
          Debian => "/usr/bin/perl -ni -e 'print unless /^\\Q${name}\\E\$/' '${modulesfile}'",
          redhat => "/usr/bin/perl -ni -e 'print unless /^\\Q/sbin/modprobe ${name}\\E\$/' '${modulesfile}'"
        },
        onlyif => $operatingsystem ? {
          Debian => "/bin/grep -qFx '${name}' '${modulesfile}'",
          redhat => "/bin/grep -q '^/sbin/modprobe ${name}' '${modulesfile}'"
        }
      }
    }
    default: { err ( "unknown ensure value ${ensure}" ) }
  }
}
