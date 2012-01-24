# Author: Kumina bv <support@kumina.nl>

# Copyright (C) 2010 Kumina bv, Ed Schouten <ed@kumina.nl>
# This works is published under the Creative Commons Attribution-Share
# Alike 3.0 Unported license - http://creativecommons.org/licenses/by-sa/3.0/
# See LICENSE for the full legal text.

# Class: hosthenker
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class hosthenker {
  kfile { "/usr/bin/hosthenker":
    ensure => absent,
  }
}
