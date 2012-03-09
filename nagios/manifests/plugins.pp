# Author: Kumina bv <support@kumina.nl>

# Class: nagios::plugins
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class nagios::plugins {
  kpackage { "nagios-plugins-basic":
    ensure => installed;
  }

  file {
    "/usr/local/lib/nagios":
      ensure => directory,
      group  => "staff",
      mode   => 2775;
    "/usr/local/lib/nagios/plugins":
      ensure => directory,
      group  => "staff";
  }
}
