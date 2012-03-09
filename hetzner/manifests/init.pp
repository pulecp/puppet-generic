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
  include hetzner::failover_ip
  include hetzner::update_dns

  if defined(Kpackage["pacemaker"]) {
    file { "/usr/lib/ocf/resource.d/kumina":
      ensure  => directory,
      require => Kpackage["pacemaker"],
    }
  }
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
  include hetzner

  kpackage { "python-simplejson":
    ensure => latest,
  }

  file { "/usr/local/sbin/parse-hetzner-json.py":
    content => template("hetzner/parse-hetzner-json.py"),
    mode    => 755,
  }

  file { "/usr/local/lib/hetzner":
    ensure => directory,
  }

  file { "/usr/local/lib/hetzner/hetzner-failover-ip":
    content => template("hetzner/hetzner-failover-ip"),
    mode    => 755,
  }

  if defined(Kpackage["pacemaker"]) {
    file { "/usr/lib/ocf/resource.d/kumina/hetzner-failover-ip":
      ensure  => link,
      target  => "/usr/local/lib/hetzner/hetzner-failover-ip",
    }
  }
}

# Class: hetzner::update_dns
#
# Actions:
#  Add update_dns script to kumina ocf scripts directory
#
# Depends:
#  hetzner
#  gen_puppet
#
class hetzner::update_dns {
  include hetzner

  if defined(Kpackage["pacemaker"]) {
    file { "/usr/lib/ocf/resource.d/kumina/update-dns":
      content => template("hetzner/update-dns"),
      mode    => 755,
    }
  }
}
