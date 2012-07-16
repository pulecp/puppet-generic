# Author: Kumina bv <support@kumina.nl>

# Class: gen_pagespeed
#
# Actions:
#  Set up mod_pagespeed.
#
# Depends:
#  gen_puppet
#
class gen_pagespeed {
  gen_apt::source { "mod_pagespeed":
    uri          => 'http://dl.google.com/linux/mod-pagespeed/deb/',
    components   => ['main'],
    key          => '7FAC5991',
  }

  gen_apt::key { '7FAC5991':
    content => template("gen_pagespeed/apt.key"),
  }

  package { "mod-pagespeed-beta":
    ensure => latest,
  }
}
