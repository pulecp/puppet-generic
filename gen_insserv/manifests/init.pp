# Author: Kumina bv <support@kumina.nl>

# Class: gen_insserv
#
# Actions: Doesn't do anything, because I have no idea what it should do. It just looks nice.
#
class gen_insserv {
}

# Define: gen_insserv::disable_script
#
# Actions: Disable an initscript at all levels (boot, start and stop).
#
# Parameters:
#  name: The script to disable
#
define gen_insserv::disable_script () {
  exec { "/sbin/insserv -r ${name}":
    onlyif => "/bin/cat /etc/init.d/.depend.boot /etc/init.d/.depend.start /etc/init.d/.depend.stop | /bin/grep ${name}",
  }
}

