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
  package { "nagios-plugins-basic":
    ensure => installed;
  }

  if $lsbdistcodename == 'squeeze' {
    gen_apt::preference { 'nagios-plugins-basic':; }
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
