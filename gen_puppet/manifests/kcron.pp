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
#  command
#    The command of the crontab entry
#
# Actions:
#  Add an entry to the crontab of the system
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kcron ($minute="*", $hour="*", $mday="*", $month="*", $wday="*", $user="root", $command) {
  kfile { "/etc/cron.d/$name":
    content => "$minute $hour $mday $month $wday $user $command\n",
    notify  => Exec["reload-cron"];
  }
}
