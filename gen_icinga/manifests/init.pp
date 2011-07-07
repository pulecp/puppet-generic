# Author: Kumina bv <support@kumina.nl>

# Class: gen_icinga::client
#
# Actions:
#	Install packages needed for Icinga monitoring
#
# Depends:
#	gen_base::nagios-plugins-standard
#
class gen_icinga::client {
	include gen_base::nagios-plugins-standard
}

# Class: gen_icinga::server
#
# Actions:
#	Set up an Icinga server
#
# Depends:
#	gen_puppet
#	gen_base::nagios-nrpe-plugin
#	gen_base::curl
#
class gen_icinga::server {
	include gen_base::nagios-nrpe-plugin
	include gen_base::curl

	kpackage { "icinga-doc":; }

	kservice { "icinga":
		ensure     => running,
		hasrestart => true,
		hasstatus  => true,
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
#	arguments
#		Set the arguments of the check, defaults to false
#	conf_dir
#		The config dir the service file will be placed in
#	nrpe
#		Defines whether the check is run throught nrpe, defaults to false
#	ensure
#		Standard ensure
#	name
#		Same as Icinga
#	host_name
#		Same as Icinga, defaults to $fqdn
#	hostgroup_name
#		Same as Icinga
#	initial_state
#		Same as Icinga
#	active_checks_enabled
#		Same as Icinga
#	event_handler_enabled
#		Same as Icinga
#	passive_checks_enabled
#		Same as Icinga
#	flap_detection_enabled
#		Same as Icinga
#	process_perf_data
#		Same as Icinga
#	retry_interval
#		Same as Icinga
#	retain_status_information
#		Same as Icinga
#	notification_period
#		Same as Icinga
#	notification_options
#		Same as Icinga
#	contact_groups
#		Same as Icinga
#	contacts
#		Same as Icinga
#	register
#		Same as Icinga
#	use
#		Same as Icinga
#	service_description
#		Same as Icinga
#	obsess_over_service
#		Same as Icinga
#	check_freshness
#		Same as Icinga
#	freshnessthreshold
#		Same as Icinga
#	retain_nonstatus_information
#		Same as Icinga
#	notifications_enabled
#		Same as Icinga
#	notification_interval
#		Same as Icinga
#	is_volatile
#		Same as Icinga
#	check_period
#		Same as Icinga
#	servicegroups
#		Same as Icinga
#	check_interval
#		Same as Icinga
#	max_check_attempts
#		Same as Icinga
#	check_command
#		Same as Icinga
#
# Actions:
#	Define a service
#
# Depends:
#	gen_puppet
#
define gen_icinga::service($conf_dir="${environment}/${fqdn}", $use=false, $service_description=false, $servicegroups=false,
		$host_name=$fqdn, $hostgroup_name=false, $initial_state=false, $active_checks_enabled=false, $passive_checks_enabled=false,
		$obsess_over_service=false, $check_freshness=false, $freshness_threshold=false, $notifications_enabled=false, $event_handler_enabled=false, $flap_detection_enabled=false,
		$process_perf_data=false, $retain_status_information=false, $retain_nonstatus_information=false, $notification_interval=false, $is_volatile=false, $check_period=false,
		$check_interval=false, $retry_interval=false, $notification_period=false, $notification_options=false, $contact_groups=false, $contacts=false,
		$max_check_attempts=false, $check_command=false, $arguments=false, $register=false, $nrpe=false, $ensure=present) {
	@@ekfile { "/etc/icinga/config/${conf_dir}/service_${name}.cfg;${fqdn}":
		content => template("gen_icinga/service"),
		notify  => Exec["reload-icinga"],
		tag     => "icinga_config",
		ensure  => $ensure;
	}
}

# Define: gen_icinga::host
#
# Parameters:
#	conf_dir
#		The config dir the host file will be placed in
#	address
#		Same as Icinga, defaults to $ipaddress
#	initial_state
#		Same as Icinga
#	notifications_enabled
#		Same as Icinga
#	event_handler_enabled
#		Same as Icinga
#	notification_period
#		Same as Icinga
#	flap_detection_enabled
#		Same as Icinga
#	notification_interval
#		Same as Icinga
#	contact_groups
#		Same as Icinga
#	contacts
#		Same as Icinga
#	max_check_attempts
#		Same as Icinga
#	use
#		Same as Icinga
#	hostgroups
#		Same as Icinga
#	parents
#		Same as Icinga
#	process_perf_data
#		Same as Icinga
#	retain_status_information
#		Same as Icinga
#	retain_nonstatus_information
#		Same as Icinga
#	check_command
#		Same as Icinga
#	register
#		Same as Icinga
#	check_interval
#		Same as Icinga
#
# Actions:
#	Define a host
#
# Depends:
#	gen_puppet
#
define gen_icinga::host($conf_dir="${environment}/${fqdn}", $use=false, $hostgroups=false, $parents=false, $address=$ipaddress, $initial_state=false,
		$notifications_enabled=false, $event_handler_enabled=false, $flap_detection_enabled=false, $process_perf_data=false, $retain_status_information=false, $retain_nonstatus_information=false,
		$check_command=false, $check_interval=false, $notification_period=false, $notification_interval=false, $contact_groups=false, $contacts=false,
		$max_check_attempts=false, $register=false) {
	@@ekfile { "/etc/icinga/config/${conf_dir}/host_${name}.cfg;${fqdn}":
		content => template("gen_icinga/host"),
		notify  => Exec["reload-icinga"],
		tag     => "icinga_config";
	}
}

# Define: gen_icinga::hostgroup
#
# Parameters:
#	hg_alias
#		The alias param in Icinga
#	members
#		Same as Icinga
#	conf_dir
#		The config dir the hostgroup file will be placed in
#
# Actions:
#	Define a hostgroup
#
# Depends:
#	gen_puppet
#
define gen_icinga::hostgroup($hg_alias, $conf_dir="${environment}/${fqdn}", $members=false) {
	@@ekfile { "/etc/icinga/config/${conf_dir}/hostgroup_${name}.cfg;${fqdn}":
		content => template("gen_icinga/hostgroup"),
		notify  => Exec["reload-icinga"],
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
#	arguments
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
define gen_icinga::servercommand($conf_dir=false, $commandname=false, $host_argument='-H $HOSTADDRESS$', $arguments=false, $nrpe=false, $time_out=30) {
	$conf_dir_name = $conf_dir ? {
		false => "${environment}/${fqdn}",
		default => $conf_dir,
	}

	@@ekfile { "/etc/icinga/config/${conf_dir_name}/command_${name}.cfg;${fqdn}":
		content => template("gen_icinga/command"),
		notify  => Exec["reload-icinga"],
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
		tag     => "icinga_config";
	}
}
