# Author: Kumina bv <support@kumina.nl>

# Class: gen_icinga::client
#
# Actions:
#  Install packages needed for Icinga monitoring
#
# Depends:
#  gen_base::nagios-plugins-standard
#
class gen_icinga::client {
  include gen_base::nagios-plugins-standard
}

# Class: gen_icinga::server
#
# Actions:
#  Set up an Icinga server
#
# Depends:
#  gen_puppet
#  gen_base::nagios-nrpe-plugin
#  gen_base::curl
#
class gen_icinga::server {
  include gen_base::nagios-nrpe-plugin
  include gen_base::curl

  kpackage { "icinga-doc":; }

  kservice {
    "ido2db":
      package => "icinga-idoutils";
    "icinga":
      require => Kservice["ido2db"];
  }

  file {
    "/var/lib/icinga/rw":
      ensure  => directory,
      owner   => "nagios",
      group   => "www-data",
      mode    => 750,
      require => Package["icinga"];
    "/var/lib/icinga/rw/icinga.cmd":
      owner   => "nagios",
      group   => "www-data",
      mode    => 660;
    "/etc/icinga/send_sms.cfg":
      content => template("gen_icinga/server/send_sms.cfg"),
      group   => "nagios",
      mode    => 640,
      require => Package["icinga"];
    "/usr/local/bin/send_sms":
      content => template("gen_icinga/server/send_sms"),
      group   => "nagios",
      mode    => 755,
      require => [File["/etc/icinga/send_sms.cfg"], Package["curl"]];
  }
}

# Define: gen_icinga::service
#
# Parameters:
#  arguments
#    Set the arguments of the check, defaults to false
#  conf_dir
#    The config dir the service file will be placed in
#  ensure
#    Standard ensure
#  name
#    Same as Icinga
#  host_name
#    Same as Icinga
#  hostgroup_name
#    Same as Icinga
#  initial_state
#    Same as Icinga
#  active_checks_enabled
#    Same as Icinga
#  event_handler_enabled
#    Same as Icinga
#  passive_checks_enabled
#    Same as Icinga
#  flap_detection_enabled
#    Same as Icinga
#  process_perf_data
#    Same as Icinga
#  retry_interval
#    Same as Icinga
#  retain_status_information
#    Same as Icinga
#  notification_period
#    Same as Icinga
#  notification_options
#    Same as Icinga
#  contact_groups
#    Same as Icinga
#  contacts
#    Same as Icinga
#  register
#    Same as Icinga
#  use
#    Same as Icinga
#  service_description
#    Same as Icinga
#  obsess_over_service
#    Same as Icinga
#  check_freshness
#    Same as Icinga
#  freshnessthreshold
#    Same as Icinga
#  retain_nonstatus_information
#    Same as Icinga
#  notifications_enabled
#    Same as Icinga
#  notification_interval
#    Same as Icinga
#  is_volatile
#    Same as Icinga
#  check_period
#    Same as Icinga
#  servicegroups
#    Same as Icinga
#  check_interval
#    Same as Icinga
#  max_check_attempts
#    Same as Icinga
#  check_command
#    Same as Icinga
#  proxy
#    Defines a proxy through which the checks are run, defaults to false
#
# Actions:
#  Define a service
#
# Depends:
#  gen_puppet
#
define gen_icinga::service($conf_dir="${environment}/${fqdn}", $use=false, $service_description=false, $servicegroups=false,
    $host_name=false, $hostgroup_name=false, $initial_state=false, $active_checks_enabled=false, $passive_checks_enabled=false,
    $obsess_over_service=false, $check_freshness=false, $freshness_threshold=false, $notifications_enabled=false, $event_handler_enabled=false, $flap_detection_enabled=false,
    $process_perf_data=false, $retain_status_information=false, $retain_nonstatus_information=false, $notification_interval=false, $is_volatile=false, $check_period=false,
    $check_interval=false, $retry_interval=false, $notification_period=false, $notification_options=false, $contact_groups=false, $contacts=false,
    $max_check_attempts=false, $check_command=false, $arguments=false, $register=false, $ensure=present, $proxy=false) {
  if $::monitoring == "true" {
    @@ekfile { "/etc/icinga/config/${conf_dir}/service_${name}.cfg;${::fqdn}":
      content => template("gen_icinga/service"),
      notify  => Exec["reload-icinga"],
      tag     => "icinga_config",
      ensure  => $ensure;
    }
  } else {
    @@ekfile { "/etc/icinga/config/${conf_dir}/service_${name}.cfg;${::fqdn}":
      ensure => absent;
    }
  }
}

# Define: gen_icinga::host
#
# Parameters:
#  conf_dir
#    The config dir the host file will be placed in
#  address
#    Same as Icinga, defaults to $ipaddress
#  initial_state
#    Same as Icinga
#  notifications_enabled
#    Same as Icinga
#  event_handler_enabled
#    Same as Icinga
#  notification_period
#    Same as Icinga
#  flap_detection_enabled
#    Same as Icinga
#  notification_interval
#    Same as Icinga
#  contact_groups
#    Same as Icinga
#  contacts
#    Same as Icinga
#  max_check_attempts
#    Same as Icinga
#  use
#    Same as Icinga
#  hostgroups
#    Same as Icinga
#  parents
#    Same as Icinga
#  process_perf_data
#    Same as Icinga
#  retain_status_information
#    Same as Icinga
#  retain_nonstatus_information
#    Same as Icinga
#  check_command
#    Same as Icinga
#  register
#    Same as Icinga
#  check_interval
#    Same as Icinga
#  proxy
#    Defines a proxy through which the checks are run, defaults to false
#
# Actions:
#  Define a host
#
# Depends:
#  gen_puppet
#
define gen_icinga::host($conf_dir="${environment}/${fqdn}", $use=false, $hostgroups=false, $parents=false, $address=$ipaddress, $initial_state=false, $ensure=present,
    $notifications_enabled=false, $event_handler_enabled=false, $flap_detection_enabled=false, $process_perf_data=false, $retain_status_information=false, $retain_nonstatus_information=false,
    $check_command="check_ping", $check_interval=false, $notification_period=false, $notification_interval=false, $contact_groups=false, $contacts=false,
    $max_check_attempts=false, $register=false, $proxy=false) {
  if $::monitoring == "true" {
    @@ekfile { "/etc/icinga/config/${conf_dir}/host_${name}.cfg;${fqdn}":
      ensure  => $ensure,
      content => template("gen_icinga/host"),
      notify  => Exec["reload-icinga"],
      tag     => "icinga_config";
    }
  } else {
    @@ekfile { "/etc/icinga/config/${conf_dir}/host_${name}.cfg;${fqdn}":
      ensure => absent;
    }
  }
}

# Define: gen_icinga::hostgroup
#
# Parameters:
#  hg_alias
#    The alias param in Icinga
#  members
#    Same as Icinga
#  conf_dir
#    The config dir the hostgroup file will be placed in
#
# Actions:
#  Define a hostgroup
#
# Depends:
#  gen_puppet
#
define gen_icinga::hostgroup($hg_alias, $conf_dir="${environment}/${fqdn}", $members=false) {
  if $::monitoring == "true" {
    @@ekfile { "/etc/icinga/config/${conf_dir}/hostgroup_${name}.cfg;${fqdn}":
      content => template("gen_icinga/hostgroup"),
      notify  => Exec["reload-icinga"],
      tag     => "icinga_config";
    }
  } else {
    @@ekfile { "/etc/icinga/config/${conf_dir}/hostgroup_${name}.cfg;${fqdn}":
      ensure => absent;
    }
  }
}

# Define: gen_icinga::servicegroup
#
# Parameters:
#  sg_alias
#    The alias param in Icinga
#  conf_dir
#    The config dir the servicegroup file will be placed in
#
# Actions:
#  Define a servicegroup
#
# Depends:
#  gen_puppet
#
define gen_icinga::servicegroup($sg_alias, $conf_dir="${environment}/${fqdn}") {
  if $::monitoring == "true" {
    @@ekfile { "/etc/icinga/config/${conf_dir}/servicegroup_${name}.cfg;${fqdn}":
      content => template("gen_icinga/servicegroup"),
      notify  => Exec["reload-icinga"],
      tag     => "icinga_config";
    }
  } else {
    @@ekfile { "/etc/icinga/config/${conf_dir}/servicegroup_${name}.cfg;${fqdn}":
      ensure => absent;
    }
  }
}

# Define: gen_icinga::contactgroup
#
# Parameters:
#  cg_alias
#    The alias param in Icinga
#  conf_dir
#    The config dir the contactgroup file will be placed in
#
# Actions:
#  Define a contactgroup
#
# Depends:
#  gen_puppet
#
define gen_icinga::contactgroup($cg_alias, $conf_dir="${environment}/${fqdn}") {
  if $::monitoring == "true" {
    @@ekfile { "/etc/icinga/config/${conf_dir}/contactgroup_${name}.cfg;${fqdn}":
      content => template("gen_icinga/contactgroup"),
      notify  => Exec["reload-icinga"],
      tag     => "icinga_config";
    }
  } else {
    @@ekfile { "/etc/icinga/config/${conf_dir}/contactgroup_${name}.cfg;${fqdn}":
      ensure => absent;
    }
  }
}

# Define: gen_icinga::contact
#
# Parameters:
#  c_alias
#    The alias param in Icinga
#  timeperiod
#    Same as Icinga
#  notification_type
#    Same as Icinga
#  contactgroups
#    Same as Icinga
#  contact_data
#    Same as Icinga
#  conf_dir
#    The config dir the contact file will be placed in
#
# Actions:
#  Define a contact
#
# Depends:
#  gen_puppet
#
define gen_icinga::contact($c_alias, $contact_data=false, $notification_type=false, $conf_dir="${environment}/${fqdn}", $timeperiod="24x7", $contactgroups=false,
    $host_notifications_enabled=1, $service_notifications_enabled=1, $ensure=present) {
  $real_notification_type = $contact_data ? {
    false   => "no-notify",
    default => $notification_type ? {
      false   => "email",
      default => $notification_type,
    },
  }

  if $::monitoring == "true" {
    @@ekfile { "/etc/icinga/config/${conf_dir}/contact_${name}.cfg;${fqdn}":
      ensure  => $ensure,
      content => template("gen_icinga/contact"),
      notify  => Exec["reload-icinga"],
      tag     => "icinga_config";
    }
  } else {
    @@ekfile { "/etc/icinga/config/${conf_dir}/contact_${name}.cfg;${fqdn}":
      ensure  => absent;
    }
  }
}

# Define: gen_icinga::timeperiod
#
# Parameters:
#  tp_alias
#    The alias param in Icinga
#  sunday
#    Same as Icinga
#  monday
#    Same as Icinga
#  tuesday
#    Same as Icinga
#  wednesday
#    Same as Icinga
#  thursday
#    Same as Icinga
#  friday
#    Same as Icinga
#  saturday
#    Same as Icinga
#  conf_dir
#    Same as Icinga
#
# Actions:
#  Define a timeperiod
#
# Depends:
#  gen_puppet
#
define gen_icinga::timeperiod($tp_alias, $conf_dir="${environment}/${fqdn}", $monday=false, $tuesday=false, $wednesday=false, $thursday=false, $friday=false, $saturday=false, $sunday=false) {
  if $::monitoring == "true" {
    @@ekfile { "/etc/icinga/config/${conf_dir}/timeperiod_${name}.cfg;${fqdn}":
      content => template("gen_icinga/timeperiod"),
      notify  => Exec["reload-icinga"],
      tag     => "icinga_config";
    }
  } else {
    @@ekfile { "/etc/icinga/config/${conf_dir}/timeperiod_${name}.cfg;${fqdn}":
      ensure => absent;
    }
  }
}

# Define: gen_icinga::configdir
#
# Param:
#  base:
#    Defines the base dir of the config
#
# Actions:
#  Define a configdir
#
# Depends:
#  gen_puppet
#
define gen_icinga::configdir($ensure="present",$base="/etc/icinga/config") {
  if $::monitoring == "true" {
    @@ekfile { "${base}/${name};${fqdn}":
      ensure  => $ensure ? {
        "present" => "directory",
        "absent"  => "absent",
        default   => "directory",
      },
      purge   => true,
      recurse => true,
      force   => true,
      tag     => "icinga_config",
      notify  => Exec["reload-icinga"];
    }
  } else {
    @@ekfile { "${base}/${name};${fqdn}":
      ensure => absent;
    }
  }
}

# Define: gen_icinga::servercommand
#
# Parameters:
#  time_out
#    If the check is run through nrpe this defines the timeout
#  command_name
#    Same as Icinga
#  host_argument
#    Defines how the check expects to receive the host argument, defaults to -H $HOSTADDRESS
#  arguments
#    All arguments of the check
#  nrpe
#    Defines whether the check should be run through nrpe, defaults to false
#  conf_dir
#    The config dir the servercommand will be placed in
#
# Actions:
#  Define a servercommand
#
# Depends:
#  gen_puppet
#
define gen_icinga::servercommand($conf_dir="${environment}/${fqdn}", $command_name=false, $host_argument='-H $HOSTADDRESS$', $arguments=false, $nrpe=false, $time_out=30) {
  if $::monitoring == "true" {
    @@ekfile {
      "/etc/icinga/config/${conf_dir}/command_${name}.cfg;${fqdn}":
        content => template("gen_icinga/command"),
        notify  => Exec["reload-icinga"],
        tag     => "icinga_config";
      "/etc/icinga/config/${conf_dir}/command_proxy_${name}.cfg;${fqdn}":
        content => template("gen_icinga/proxycommand"),
        notify  => Exec["reload-icinga"],
        tag     => "icinga_config";
    }
  } else {
    @@ekfile { ["/etc/icinga/config/${conf_dir}/command_${name}.cfg;${fqdn}","/etc/icinga/config/${conf_dir}/command_proxy_${name}.cfg;${fqdn}"]:
      ensure => absent;
    }
  }
}

# Define: gen_icinga::hostescalation
#
# Parameters:
#  last_notification
#    Same as Icinga
#  contacts
#    Same as Icinga
#  escalation_period
#    Same as Icinga
#  conf_dir
#    The config dir the hostescalation will be placed in
#  host_name
#    Same ass Icinga
#  notification_interval
#    Same as Icinga
#  hostgroup_name
#    Same as Icinga
#  escalation_options
#    Same as Icinga
#  first_notification
#    Same as Icinga
#  contact_groups
#    Same as Icinga
#
# Actions:
#  Define a hostescalation
#
# Depends:
#  gen_puppet
#
define gen_icinga::hostescalation($escalation_period, $contact_groups="${environment}/${fqdn}", $contacts=false, $conf_dir=false, $host_name=false, $hostgroup_name=false, $escalation_options=false, $first_notification=1, $last_notification=0, $notification_interval=0) {
  if $::monitoring == "true" {
    @@ekfile { "/etc/icinga/config/${conf_dir}/host_escalation_${name}.cfg;${fqdn}":
      content => template("gen_icinga/hostescalation"),
      notify  => Exec["reload-icinga"],
      tag     => "icinga_config";
    }
  } else {
    @@ekfile { "/etc/icinga/config/${conf_dir}/host_escalation_${name}.cfg;${fqdn}":
      ensure => absent;
    }
  }
}

# Define: gen_icinga::serviceescalation
#
# Parameters:
#  escalation_options
#    Same as Icinga
#  contacts
#    Same as Icinga
#  escalation_period
#    Same as Icinga
#  conf_dir
#    The config dir the serviceescalation file will be placed in
#  host_name
#    Same as Icinga
#  first_notification
#    Same as Icinga
#  hostgroup_name
#    Same as Icinga
#  last_notification
#    Same as Icinga
#  servicegroup_name
#    Same as Icinga
#  notification_interval
#    Same as Icinga
#  service_description
#    Same as Icinga
#  contact_groups
#    Same as Icinga
#
# Actions:
#  Define a serviceescalation
#
# Depends:
#  gen_puppet
#
define gen_icinga::serviceescalation($escalation_period, $contact_groups=false, $contacts=false, $conf_dir="${environment}/${fqdn}", $host_name=false, $hostgroup_name=false, $servicegroup_name=false, $service_description="*", $escalation_options=false, $first_notification=1, $last_notification=0, $notification_interval=0) {
  if $::monitoring == "true" {
    @@ekfile { "/etc/icinga/config/${conf_dir}/service_escalation_${name}.cfg;${fqdn}":
      content => template("gen_icinga/serviceescalation"),
      notify  => Exec["reload-icinga"],
      tag     => "icinga_config";
    }
  } else {
    @@ekfile { "/etc/icinga/config/${conf_dir}/service_escalation_${name}.cfg;${fqdn}":
      ensure => absent;
    }
  }
}

# Define: gen_icinga::servicedependency
#
# Parameters:
#  host_name
#    Same as Icinga
#  service_description
#    Same as Icinga
#  conf_dir
#    The config dir the serviceddependency file will be placed in
#  dependent_host_name
#    Same as Icinga
#  fqdn
#    Same as Icinga
#  execution_failure_criteria
#    Same as Icinga
#  notification_failure_criteria
#    Same as Icinga
#  dependent_service_description
#    Same as Icinga
#
# Actions:
#  Define a servicedependency
#
# Depends:
#  gen_puppet
#
define gen_icinga::servicedependency($ensure="present", $dependent_service_description, $host_name, $service_description, $conf_dir="${environment}/${fqdn}", $dependent_host_name=$fqdn,
    $execution_failure_criteria=false, $notification_failure_criteria="o") {
  if $::monitoring == "true" {
    @@ekfile { "/etc/icinga/config/${conf_dir}/service_dependency_${name}.cfg;${fqdn}":
      ensure  => $ensure,
      content => template("gen_icinga/servicedependency"),
      notify  => Exec["reload-icinga"],
      tag     => "icinga_config";
    }
  } else {
    @@ekfile { "/etc/icinga/config/${conf_dir}/service_dependency_${name}.cfg;${fqdn}":
      ensure => absent;
    }
  }
}
