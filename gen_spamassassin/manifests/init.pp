# Author: Kumina bv <support@kumina.nl>

# Class: gen_spamassassin
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class gen_spamassassin {
  package { ["spamassassin","libmail-spf-perl", "libmail-dkim-perl"]:; }

  file { "/etc/default/spamassassin":
    content => template("gen_spamassassin/spamassassin");
  }
}
