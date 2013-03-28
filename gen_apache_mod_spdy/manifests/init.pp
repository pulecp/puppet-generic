# Author: Kumina bv <support@kumina.nl>

# Class: gen_apache_mod_spdy
#
# Actions:
#  Install the mod_spdy package from Google for Apache. Installing will automatically enable it.
#
class gen_apache_mod_spdy {
  gen_apt::source { 'mod_spdy':
    uri => 'http://dl.google.com/linux/mod-spdy/deb/',
    components => 'main';
  }

  gen_apt::key { '7FAC5991':
    content => template('gen_apache_mod_spdy/google-key');
  }

  package { 'mod-spdy-beta':
    ensure => latest,
  }
}
