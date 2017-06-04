class docker-setup {
	notify { '[docker-setup] Installing Docker and configuring for remote API accss': withpath => false }

	package { 'docker':
		ensure => installed,
		allow_virtual => false
	}
}
