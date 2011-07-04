# Author: Kumina bv <support@kumina.nl>

# Class: gen_icinga::client
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_icinga::client {
	kpackage { ["nagios-plugins-standard","dnsutils"]:
		ensure => latest;
	}
}

# Class: gen_icinga::server
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_icinga::server {
	kpackage { ["icinga","icinga-doc","nagios-nrpe-plugin","curl"]:; }

	service { "icinga":
		ensure     => running,
		hasrestart => true,
		hasstatus  => true,
		require    => Package["icinga"];
	}

	exec { "reload-icinga":
		command     => "/etc/init.d/icinga reload",
		refreshonly => true;
	}

	kfile {
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
			source  => "gen_icinga/server/send_sms.cfg",
			group   => "nagios",
			mode    => 640,
			require => Package["icinga"];
		"/usr/local/bin/send_sms":
			source  => "gen_icinga/server/send_sms",
			group   => "nagios",
			mode    => 755,
			require => [File["/etc/icinga/send_sms.cfg"], Package["curl"]];
	}
}

# Define: gen_icinga::service
#
# Parameters:
#	hostname
#		Undocumented
#	fqdn
#		Undocumented
#	hostgroup_name
#		Undocumented
#	initialstate
#		Undocumented
#	active_checks_enabled
#		Undocumented
#	event_handler_enabled
#		Undocumented
#	passive_checks_enabled
#		Undocumented
#	flap_detection_enabled
#		Undocumented
#	failure_prediction_enabled
#		Undocumented
#	process_perf_data
#		Undocumented
#	retry_interval
#		Undocumented
#	retain_status_information
#		Undocumented
#	notification_period
#		Undocumented
#	notification_options
#		Undocumented
#	contact_groups
#		Undocumented
#	argument3
#		Undocumented
#	conf_dir
#		Undocumented
#	contacts
#		Undocumented
#	register
#		Undocumented
#	use
#		Undocumented
#	nrpe
#		Undocumented
#	service_description
#		Undocumented
#	servicegroups
#		Undocumented
#	parallelize_check
#		Undocumented
#	obsess_over_service
#		Undocumented
#	check_freshness
#		Undocumented
#	freshnessthreshold
#		Undocumented
#	retain_nonstatus_information
#		Undocumented
#	notifications_enabled
#		Undocumented
#	notification_interval
#		Undocumented
#	is_volatile
#		Undocumented
#	check_period
#		Undocumented
#	servicegroups
#		Undocumented
#	check_interval
#		Undocumented
#	max_check_attempts
#		Undocumented
#	checkcommand
#		Undocumented
#	argument1
#		Undocumented
#	argument2
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define gen_icinga::service($conf_dir=false, $use="warnsms_service", $service_description=false, $servicegroups=false, $hostname=$fqdn, $hostgroup_name=false, $initialstate=false, $active_checks_enabled=false, $passive_checks_enabled=false, $parallelize_check=false, $obsess_over_service=false, $check_freshness=false, $freshnessthreshold=false, $notifications_enabled=false, $event_handler_enabled=false, $flap_detection_enabled=false, $failure_prediction_enabled=false, $process_perf_data=false, $retain_status_information=false, $retain_nonstatus_information=false, $notification_interval=false, $is_volatile=false, $check_period=false, $check_interval=false, $retry_interval=false, $notification_period=false, $notification_options=false, $contact_groups=false, $contacts=false, $servicegroups=false, $max_check_attempts=false, $checkcommand=false, $argument1=false, $argument2=false, $argument3=false, $register=false, $nrpe=false) {
	$conf_dir_name = $conf_dir ? {
		false   => "${environment}/${fqdn}",
		default => $conf_dir,
	}

	@@ekfile { "/etc/icinga/config/${conf_dir_name}/service_${name}.cfg;${fqdn}":
		content => template("gen_icinga/service"),
		notify  => Exec["reload-icinga"],
		require => File["/etc/icinga/config/${conf_dir_name}"],
		tag     => "icinga_config";
	}

	if $nrpe and $hostname == $fqdn and !defined(Kfile["/etc/nagios/nrpe.d/${checkcommand}.cfg"]) {
		kfile { "/etc/nagios/nrpe.d/${checkcommand}.cfg":
				source  => "gen_icinga/client/${checkcommand}.cfg",
				require => Package["nagios-nrpe-server"];
		}
	}
}

# Define: gen_icinga::host
#
# Parameters:
#	address
#		Undocumented
#	ipaddress
#		Undocumented
#	initialstate
#		Undocumented
#	notifications_enabled
#		Undocumented
#	event_handler_enabled
#		Undocumented
#	notification_period
#		Undocumented
#	flap_detection_enabled
#		Undocumented
#	notification_interval
#		Undocumented
#	contact_groups
#		Undocumented
#	contacts
#		Undocumented
#	max_check_attempts
#		Undocumented
#	conf_dir
#		Undocumented
#	use
#		Undocumented
#	hostgroups
#		Undocumented
#	parents
#		Undocumented
#	process_perf_data
#		Undocumented
#	retain_status_information
#		Undocumented
#	retain_nonstatus_information
#		Undocumented
#	check_command
#		Undocumented
#	register
#		Undocumented
#	check_interval
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define gen_icinga::host($conf_dir=false, $use="wh_host", $hostgroups="wh_hosts", $parents=false, $address=$ipaddress, $initialstate=false, $notifications_enabled=false, $event_handler_enabled=false, $flap_detection_enabled=false, $process_perf_data=false, $retain_status_information=false, $retain_nonstatus_information=false, $check_command=false, $check_interval=false, $notification_period=false, $notification_interval=false, $contact_groups=false, $contacts=false, $max_check_attempts=false, $register=false) {
	$conf_dir_name = $conf_dir ? {
		false   => "${environment}/${name}",
		default => $conf_dir,
	}

	@@ekfile { "/etc/icinga/config/${conf_dir_name}/host_${name}.cfg;${fqdn}":
		content => template("gen_icinga/host"),
		notify  => Exec["reload-icinga"],
		require => File["/etc/icinga/config/${conf_dir_name}"],
		tag     => "icinga_config";
	}
}

# Define: gen_icinga::hostgroup
#
# Parameters:
#	hg_alias
#		Undocumented
#	members
#		Undocumented
#	conf_dir
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define gen_icinga::hostgroup($conf_dir=false, $hg_alias, $members=false) {
	$conf_dir_name = $conf_dir ? {
		false   => "${environment}/${fqdn}",
		default => $conf_dir,
	}

	@@ekfile { "/etc/icinga/config/${conf_dir_name}/hostgroup_${name}.cfg;${fqdn}":
		content => template("gen_icinga/hostgroup"),
		notify  => Exec["reload-icinga"],
		require => File["/etc/icinga/config/${conf_dir_name}"],
		tag     => "icinga_config";
	}
}

# Define: gen_icinga::servicegroup
#
# Parameters:
#	sg_alias
#		Undocumented
#	members
#		Undocumented
#	conf_dir
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define gen_icinga::servicegroup($conf_dir=false, $sg_alias, $members=false) {
	$conf_dir_name = $conf_dir ? {
		false   => "${environment}/${fqdn}",
		default => $conf_dir,
	}

	@@ekfile { "/etc/icinga/config/${conf_dir_name}/servicegroup_${name}.cfg;${fqdn}":
		content => template("gen_icinga/servicegroup"),
		notify  => Exec["reload-icinga"],
		require => File["/etc/icinga/config/${conf_dir_name}"],
		tag     => "icinga_config";
	}
}

# Define: gen_icinga::contactgroup
#
# Parameters:
#	customer
#		Undocumented
#	cg_alias
#		Undocumented
#	conf_dir
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define gen_icinga::contactgroup($conf_dir=false, $customer="generic", $cg_alias) {
	$conf_dir_name = $conf_dir ? {
		false   => "${environment}/${fqdn}",
		default => $conf_dir,
	}

	@@ekfile { "/etc/icinga/config/${conf_dir_name}/contactgroup_${name}.cfg;${fqdn}":
		content => template("gen_icinga/contactgroup"),
		notify  => Exec["reload-icinga"],
		require => File["/etc/icinga/config/${conf_dir_name}"],
		tag     => "icinga_config";
	}
}

# Define: gen_icinga::contact
#
# Parameters:
#	c_alias
#		Undocumented
#	timeperiod
#		Undocumented
#	notification_type
#		Undocumented
#	contactgroups
#		Undocumented
#	contact_data
#		Undocumented
#	conf_dir
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define gen_icinga::contact($conf_dir=false, $c_alias, $timeperiod="24x7", $notification_type, $contactgroups=false, $contact_data, host_notifications_enabled=1, service_notifications_enabled=1) {
	$conf_dir_name = $conf_dir ? {
		false   => "${environment}/${fqdn}",
		default => $conf_dir,
	}

	@@ekfile { "/etc/icinga/config/${conf_dir_name}/contact_${name}.cfg;${fqdn}":
		content => template("gen_icinga/contact"),
		notify  => Exec["reload-icinga"],
		require => File["/etc/icinga/config/${conf_dir_name}"],
		tag     => "icinga_config";
	}
}

# Define: gen_icinga::timeperiod
#
# Parameters:
#	sunday
#		Undocumented
#	tp_alias
#		Undocumented
#	monday
#		Undocumented
#	tuesday
#		Undocumented
#	wednesday
#		Undocumented
#	thursday
#		Undocumented
#	friday
#		Undocumented
#	saturday
#		Undocumented
#	conf_dir
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define gen_icinga::timeperiod($conf_dir=false, $tp_alias, $monday=false, $tuesday=false, $wednesday=false, $thursday=false, $friday=false, $saturday=false, $sunday=false) {
	$conf_dir_name = $conf_dir ? {
		false   => "${environment}/${fqdn}",
		default => $conf_dir,
	}

	@@ekfile { "/etc/icinga/config/${conf_dir_name}/timeperiod_${name}.cfg;${fqdn}":
		content => template("gen_icinga/timeperiod"),
		notify  => Exec["reload-icinga"],
		require => File["/etc/icinga/config/${conf_dir_name}"],
		tag     => "icinga_config";
	}
}

# Define: gen_icinga::configdir
#
# Parameters:
#	sub
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define gen_icinga::configdir($sub=false) {
	@@ekfile { "/etc/icinga/config/${name};${fqdn}":
		ensure  => directory,
		require => $sub ? {
			false   => Package["icinga"],
			default => [Package["icinga"],Gen_icinga::Configdir["${sub}"]],
		},
		tag     => "icinga_config";
	}
}

# Define: gen_icinga::servercommand
#
# Parameters:
#	time_out
#		Undocumented
#	commandname
#		Undocumented
#	host_argument
#		Undocumented
#	HOSTADDRESS$'
#		Undocumented
#	argument1
#		Undocumented
#	argument2
#		Undocumented
#	argument3
#		Undocumented
#	nrpe
#		Undocumented
#	conf_dir
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define gen_icinga::servercommand($conf_dir=false, $commandname=false, $host_argument='-H $HOSTADDRESS$', $argument1=false, $argument2=false, $argument3=false, $nrpe=false, $time_out=30) {
	$conf_dir_name = $conf_dir ? {
		false => "${environment}/${fqdn}",
		default => $conf_dir,
	}

	@@ekfile { "/etc/icinga/config/${conf_dir_name}/command_${name}.cfg;${fqdn}":
		content => template("gen_icinga/command"),
		notify  => Exec["reload-icinga"],
		require => File["/etc/icinga/config/${conf_dir_name}"],
		tag     => "icinga_config";
	}
}

# Define: gen_icinga::hostescalation
#
# Parameters:
#	last_notification
#		Undocumented
#	contacts
#		Undocumented
#	escalation_period
#		Undocumented
#	conf_dir
#		Undocumented
#	host_name
#		Undocumented
#	notification_interval
#		Undocumented
#	hostgroup_name
#		Undocumented
#	escalation_options
#		Undocumented
#	first_notification
#		Undocumented
#	contact_groups
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define gen_icinga::hostescalation($contact_groups=false, $contacts=false, $escalation_period, $conf_dir=false, $host_name=false, $hostgroup_name=false, $escalation_options=false, $first_notification=1, $last_notification=0, $notification_interval=0) {
	$conf_dir_name = $conf_dir ? {
		false => "${environment}/${fqdn}",
		default => $conf_dir,
	}

	@@ekfile { "/etc/icinga/config/${conf_dir_name}/host_escalation_${name}.cfg;${fqdn}":
		content => template("gen_icinga/hostescalation"),
		notify  => Exec["reload-icinga"],
		require => File["/etc/icinga/config/${conf_dir_name}"],
		tag     => "icinga_config";
	}
}

# Define: gen_icinga::serviceescalation
#
# Parameters:
#	escalation_options
#		Undocumented
#	contacts
#		Undocumented
#	escalation_period
#		Undocumented
#	conf_dir
#		Undocumented
#	host_name
#		Undocumented
#	first_notification
#		Undocumented
#	hostgroup_name
#		Undocumented
#	last_notification
#		Undocumented
#	servicegroup_name
#		Undocumented
#	notification_interval
#		Undocumented
#	service_description
#		Undocumented
#	contact_groups
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define gen_icinga::serviceescalation($contact_groups=false, $contacts=false, $escalation_period, $conf_dir=false, $host_name=false, $hostgroup_name=false, $servicegroup_name=false, $service_description="*", $escalation_options=false, $first_notification=1, $last_notification=0, $notification_interval=0) {
	$conf_dir_name = $conf_dir ? {
		false => "${environment}/${fqdn}",
		default => $conf_dir,
	}

	@@ekfile { "/etc/icinga/config/${conf_dir_name}/service_escalation_${name}.cfg;${fqdn}":
		content => template("gen_icinga/serviceescalation"),
		notify  => Exec["reload-icinga"],
		require => File["/etc/icinga/config/${conf_dir_name}"],
		tag     => "icinga_config";
	}
}

# Define: gen_icinga::servicedependency
#
# Parameters:
#	host_name
#		Undocumented
#	service_description
#		Undocumented
#	conf_dir
#		Undocumented
#	dependent_host_name
#		Undocumented
#	fqdn
#		Undocumented
#	execution_failure_criteria
#		Undocumented
#	notification_failure_criteria
#		Undocumented
#	dependent_service_description
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define gen_icinga::servicedependency($dependent_service_description, $host_name, $service_description, $conf_dir=false, $dependent_host_name=$fqdn, $execution_failure_criteria=false, $notification_failure_criteria="o") {
	$conf_dir_name = $conf_dir ? {
		false => "${environment}/${fqdn}",
		default => $conf_dir,
	}

	@@ekfile { "/etc/icinga/config/${conf_dir_name}/service_dependency_${name}.cfg;${fqdn}":
		content => template("gen_icinga/servicedependency"),
		notify  => Exec["reload-icinga"],
		require => File["/etc/icinga/config/${conf_dir_name}"],
		tag     => "icinga_config";
	}
}
