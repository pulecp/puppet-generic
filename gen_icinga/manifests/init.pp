class gen_icinga::client {
	kpackage { ["nagios-plugins-standard","dnsutils"]:
		ensure => latest;
	}
}

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

define gen_icinga::servercommand($conf_dir=false, $commandname=false, $host_argument='-H $HOSTADDRESS$', $argument1=false, $argument2=false, $argument3=false, $nrpe=false, $time_out=false) {
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
