class gen_icinga::server {
	kpackage { ["icinga","icinga-doc","nagios-nrpe-plugin","nagios-plugins-standard"]:; }

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
			mode    => 660,
	}
}

define gen_icinga::service($conf_dir=false, $use="generic_ha_service", $service_description=false, $hostname=$fqdn, $hostgroup_name=false, $initialstate=false, $active_checks_enabled=false, $passive_checks_enabled=false, $parallelize_check=false, $obsess_over_service=false, $check_freshness=false, $freshnessthreshold=false, $notifications_enabled=false, $event_handler_enabled=false, $flap_detection_enabled=false, $failure_prediction_enabled=false, $process_perf_data=false, $retain_status_information=false, $retain_nonstatus_information=false, $notification_interval=false, $is_volatile=false, $check_period=false, $normal_check_interval=false, $retry_check_interval=false, $notification_period=false, $notification_options=false, $contact_groups=false, $servicegroups=false, $max_check_attempts=false, $checkcommand=false, $argument1=false, $argument2=false, $argument3=false, $register=false, $nrpe=false) {
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

	if $nrpe and !defined(Kfile["/etc/nagios/nrpe.d/${checkcommand}.cfg"]) {
		kfile { "/etc/nagios/nrpe.d/${checkcommand}.cfg":
				source  => "gen_icinga/client/${checkcommand}.cfg",
				require => Package["nagios-nrpe-server"];
		}
	}
}

define gen_icinga::host($conf_dir=false, $use="generic_ha_host", $hostgroups="ha_hosts", $parents=false, $address=$ipaddress, $initialstate=false, $notifications_enabled=false, $event_handler_enabled=false, $flap_detection_enabled=false, $process_perf_data=false, $retain_status_information=false, $retain_nonstatus_information=false, $check_command=false, $check_interval=false, $notification_period=false, $notification_interval=false, $contact_groups=false, $max_check_attempts=false, $register=false) {
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

define gen_icinga::contact($conf_dir=false, $c_alias, $timeperiod="24x7", $notification_type, $contactgroups=false, $contact_data) {
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

define gen_icinga::serviceescalation($contact_groups, $conf_dir=false, $escalation_period, $host_name=false, $hostgroup_name=false, $first_notification=1, $last_notification=0, $notification_interval=0) {
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
