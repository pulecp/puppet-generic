# Author: Kumina bv <support@kumina.nl>

# Class: gen_fail2ban
#
# Actions:
#  Set up fail2ban with several default setting from Debian (rewritten into this puppet manifest).
#
# Depends:
#  gen_puppet
#
class gen_fail2ban {
  kservice { 'fail2ban':
    pensure => latest,
  }
}
