# Author: Kumina bv <support@kumina.nl>

# Class: gen_phpmyadmin
#
# Actions:
#  Set up PhpMyAdmin and keep it up-to-date.
#
# Depends:
#  gen_puppet
#
class gen_phpmyadmin {
  package { "phpmyadmin":
    ensure => latest,
  }
}

# Class: gen_phpmyadmin::cgi
#
# Actions:
#  Make sure phpmyadmin works when using php-cgi.
#
# Depends:
#  gen_puppet
#
class gen_phpmyadmin::cgi ($httpserver="apache") {
  include gen_phpmyadmin

  case $httpserver {
    'apache': {
      kaugeas {
        "Setup CGI hook for phpmyadmin.":
          file    => "/etc/phpmyadmin/apache.conf",
          lens    => "Httpd.lns",
          changes => "set Directory[arg = '/usr/share/phpmyadmin']/directive[. = 'Options']/arg[last()+1] 'ExecCGI'",
          onlyif  => "match Directory[arg = '/usr/share/phpmyadmin' and directive/arg = 'ExecCGI'] size == 0",
          require => Package["phpmyadmin"],
          notify  => Exec["reload-apache2"];
        "Setup FastCGI hook for phpmyadmin.":
          file    => "/etc/phpmyadmin/apache.conf",
          lens    => "Httpd.lns",
          changes => ["set Directory[arg = '/usr/share/phpmyadmin']/directive[last()+1] 'AddHandler'",
                      "set Directory[arg = '/usr/share/phpmyadmin']/directive[last()]/arg[1] 'fcgid-script'",
                      "set Directory[arg = '/usr/share/phpmyadmin']/directive[last()]/arg[2] '.php'",
                      "set Directory[arg = '/usr/share/phpmyadmin']/directive[last()+1] 'FCGIWrapper'",
                      "set Directory[arg = '/usr/share/phpmyadmin']/directive[last()]/arg[1] '/usr/lib/cgi-bin/php5'",
                      "set Directory[arg = '/usr/share/phpmyadmin']/directive[last()]/arg[2] '.php'"
                     ],
          onlyif  => "match Directory[arg = '/usr/share/phpmyadmin' and directive/arg = 'fcgid-script'] size == 0",
          require => Package["phpmyadmin"],
          notify  => Exec["reload-apache2"];
      }
    }
    default: {
      fail("Unknown httpserver ${httpserver} for gen_phpmyadmin::cgi.")
    }
  }
}
