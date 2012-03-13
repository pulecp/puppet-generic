# Class: gen_haveged
#
# Actions:
#  Install and start the havege daemon, an entropy generator
#
# Depends:
#  gen_puppet
class gen_haveged {
  if $::lsbmajdistrelease >= 6 {
    kservice { "haveged":
      pensure => latest;
    }
  }
}
