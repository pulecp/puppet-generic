# Author: Kumina bv <support@kumina.nl>

# Class: gen_cron
#
# Actions:
#  Install cron
#
# Depends:
#  gen_puppet
#
class gen_cron {
  kservice { "cron":
    hasstatus => false,
    pattern   => "/usr/sbin/cron"; 
  }
}
