# Author: Kumina bv <support@kumina.nl>

# Class: machdb::agent
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class machdb::agent {
  file { "/etc/machdb/agent.conf":
    owner => "root",
    group => "root",
    mode => 644,
    source => "puppet://puppet/machdb/agent.conf",
    require => Package["machdb-agent"],
  }

  package { "machdb-agent":
    ensure => installed,
  }
}
