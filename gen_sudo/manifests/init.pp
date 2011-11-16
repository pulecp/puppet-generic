# Author: Kumina bv <support@kumina.nl>

# Class: gen_sudo
#
# Actions:
#  Install sudo and set up basics
#
# Depends:
#  gen_puppet
#
class gen_sudo {
  kpackage { "sudo":; }

  # Setup /etc/sudoers for either .d inclusion or concatination
  if $lsbmajdistrelease < 6 { # Lenny and older
    concat { "/etc/sudoers":
      mode    => 440,
      require => Package["sudo"];
    }
  } else { # Squeeze and newer
    kfile {
      "/etc/sudoers.d/":
        ensure  => directory,
        recurse => true,
        purge   => true,
        mode    => 440;
      "/etc/sudoers":
        content => "#includedir /etc/sudoers.d\n",
        mode    => 440,
        require => Package["sudo"];
    }
  }
}

# Define: gen_sudo::rule
#
# Parameters:
#  entity
#    The user or group that can use the rule
#  command
#    The command that can be run
#  as_user
#    The user the command can be ran as
#  password_required
#    Is entering a password required? Defaults to true
#  comment
#    Optional comment, if none is supplied the resource name will be used
#  preserve_env_vars
#    Do the environment vars need to be preserved? Defaults to false
#
# Actions:
#  Set up a sudo rule
#
# Depends:
#  gen_sudo
#  gen_puppet
#
define gen_sudo::rule($entity, $command, $as_user, $password_required = true, $comment = false, $preserve_env_vars=false) {
  include gen_sudo
  $safe_name = regsubst($name, ' ', '_', 'G')

  $the_comment = $comment ? {
    false   => $name,
    default => $comment,
  }

  if $lsbmajdistrelease > 5 { # Squeeze or newer
    kfile { "/etc/sudoers.d/${safe_name}":
      content => template("gen_sudo/sudo"),
      mode    => 440;
    }
  } else {
    gen_sudo::add_rule { "${safe_name}":
      content => template("gen_sudo/sudo");
    }
  }
}

# Define: gen_sudo::add_rule
#
# Parameters:
#  content
#    The content of the rule
#
# Actions:
#  Internal define to add a sudo rule
#
# Depends:
#  gen_puppet
#
define gen_sudo::add_rule($content) {
  concat::add_content { $name:
    content => $content,
    target  => "/etc/sudoers";
  }
}
