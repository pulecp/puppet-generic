# Author: Kumina bv <support@kumina.nl>

# Define: kcron
#
# Parameters:
#  minute
#    Minute interval field of crontab entry
#  hour
#    Hour interval field of crontab entry
#  mday
#    Day of month interval field of crontab entry
#  month
#    Month interval field of crontab entry
#  wday
#    Day of week interval field of crontab entry
#  user
#    Which user should be used to execute the command
#  pacemaker_resource
#    In failover setups, make sure this resource is local before running the command
#  command
#    The command of the crontab entry
#
# Actions:
#  Add an entry to the crontab of the system
#
# Depends:
#  gen_puppet
#
define kcron($mailto=false, $minute="*", $hour="*", $mday="*", $month="*", $wday="*", $user="root", $pacemaker_resource=false, $command) {
  # If the name contains an underscore or dot, cron won't use the file! So fail when that's the case.
  if $name =~ /\./ or $name =~ /_/ {
    fail("Kcron names cannot contain dots or underscores. Resource: ${name}")
  }

  if $pacemaker_resource {
    # A cronjob on a host in failover, where we only want the active host
    # to run the cronjob
    file { "/etc/cron.d/$name":
      content => template("gen_puppet/kcron-pacemaker"),
      require => Kbp_sudo::Rule["Allow ${user} to check crm_resource ${pacemaker_resource}"],
      notify  => Exec["reload-cron"];
    }

    # Also make sure the user that's running this can check pacemaker with sudo
    if ! defined(Kbp_sudo::Rule["Allow ${user} to check crm_resource ${pacemaker_resource}"]) {
      kbp_sudo::rule { "Allow ${user} to check crm_resource ${pacemaker_resource}":
        entity            => $user,
        command           => "/usr/sbin/crm_resource -r ${pacemaker_resource} -W",
        as_user           => "root",
        password_required => false;
      }
    }
  } else {
    # A simple cronjob
    file { "/etc/cron.d/$name":
      content => template("gen_puppet/kcron"),
      notify  => Exec["reload-cron"];
    }
  }
}
