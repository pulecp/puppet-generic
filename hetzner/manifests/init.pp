# Author: Kumina bv <support@kumina.nl>

# Copyright (C) 2010 Kumina bv, Tim Stoop <tim@kumina.nl>
# This works is published under the Creative Commons Attribution-Share
# Alike 3.0 Unported license - http://creativecommons.org/licenses/by-sa/3.0/
# See LICENSE for the full legal text.

# Class: hetzner
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class hetzner {
}

# Class: hetzner::failover_ip
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class hetzner::failover_ip {
  kpackage { "python-simplejson":
    ensure => latest,
  }

  kfile { "/usr/local/sbin/parse-hetzner-json.py":
    source => "hetzner/parse-hetzner-json.py",
    owner  => "root",
    group  => "root",
    mode   => 755,
  }

  kfile { "/usr/local/lib/hetzner":
    ensure => directory,
  }

  kfile { "/usr/local/lib/hetzner/hetzner-failover-ip":
    source => "hetzner/hetzner-failover-ip",
    owner  => "root",
    group  => "root",
    mode   => 755,
  }

}
