class nagios-setup {
	require monitor-prereqs

	notify { '[nagios-setup] Install and configure Nagios': withpath => false }

	package { 'nagios':
		ensure => installed,
		allow_virtual => false
	}

	package { 'nagios-plugins-all':
		require => Package['nagios'],
		ensure => installed,
		allow_virtual => false
	}

	file { '/opt/nagios_plugins':
		require => Package['nagios'],
		ensure => directory,
		owner => nagios,
		group => nagios
	}

	exec { 'clone-plugins':
		require => File['/opt/nagios_plugins'],
		cwd => '/opt/nagios_plugins',
		path => '/usr/bin',
		command => 'git clone https://github.com/EthanWaldman/nagios-plugins.git .',
		onlyif => 'ls | wc -l | grep -q -w 0'
	} ->
	exec { 'clone-configs':
		require => Package['nagios'],
		cwd => '/etc/nagios/conf.d',
		path => '/usr/bin',
		command => 'git clone https://github.com/EthanWaldman/nagios-configs.git .',
		onlyif => 'ls | wc -l | grep -q -w 0'
	}
}
