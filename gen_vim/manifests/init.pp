# Author: Kumina bv <support@kumina.nl>

# Define: gen_vim::global_setting
#
# Actions:
#  Set a global setting
#
# Parameters:
#  name
#    The setting to set
#
# Depends:
#  gen_base::vim
#  gen_puppet
#
define gen_vim::global_setting {
  include gen_base::vim

  line { "global vim setting ${name}":
    file    => "/etc/vim/vimrc",
    content => $name,
    require => Package["vim"];
  }
}

# Define: gen_vim::addon
#
# Parameters:
#  package
#    The package to install, defaults to $name
#
# Actions:
#  Install and activate a vim addon
#
# Depends:
#  gen_base::vim
#  gen_base::vim-addon-manager
#  gen_puppet
#
define gen_vim::addon ($package=false) {
  include gen_base::vim
  include gen_base::vim-addon-manager

  $the_package = $package ? {
    false   => $name,
    default => $package,
  }

  kpackage { $the_package:
    ensure => latest;
  }

  exec { "/usr/bin/vim-addons -w install ${name}":
    unless  => "/usr/bin/vim-addons -w -q show ${name} | /bin/grep 'installed' 2>&1 > /dev/null",
    require => Package["vim-addon-manager", $the_package];
  }
}
