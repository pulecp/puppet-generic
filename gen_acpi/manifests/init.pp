class gen_acpi {
	kpackage { "acpi-support-base":; }

	kservice { "acpid":
		require => Kpackage["acpi-support-base"];
	}
}
