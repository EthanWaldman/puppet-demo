class nagios-setup {
	require monitor-prereqs

	notify { '[nagios-setup] Install and configure Nagios': withpath => false }

	$nagios_plugins_dir = "/opt/nagios_plugins"
	$docker_api_endpoint = "192.168.33.13:2375"

	package { 'nagios':
		ensure => installed,
		allow_virtual => false
	}

	package { 'nagios-plugins-all':
		require => Package['nagios'],
		ensure => installed,
		allow_virtual => false
	}

	file { "$nagios_plugins_dir":
		require => Package['nagios'],
		ensure => directory,
		owner => nagios,
		group => nagios
	}

	exec { 'clone-plugins':
		require => File["$nagios_plugins_dir"],
		cwd => "$nagios_plugins_dir",
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

	exec { 'config-resource-plugins-dir':
		require => Package['nagios'],
		path => '/bin',
		command => "echo '\$USER5$'=$nagios_plugins_dir >> /etc/nagios/private/resource.cfg",
		unless => "cat /etc/nagios/private/resource.cfg | grep -v '^#' | grep -q USER5"
	} ->
	exec { 'config-resource-docker-endpoint':
		require => Package['nagios'],
		path => '/bin',
		command => "echo '\$USER6$'=$docker_api_endpoint >> /etc/nagios/private/resource.cfg",
		unless => "cat /etc/nagios/private/resource.cfg | grep -v '^#' | grep -q USER6"
	}

	package { 'wget':
		require => File["$nagios_plugins_dir"],
		ensure => installed,
		allow_virtual => false
	}
	exec { 'check-docker-plugin':
		require => Package['wget'],
		path => '/bin',
		cwd => "$nagios_plugins_dir",
		command => "wget https://raw.githubusercontent.com/timdaman/check_docker/master/check_docker -O check_docker.py",
		unless => "ls check_docker.py > /dev/null 2>&1"
	}
	file { "$nagios_plugins_dir/check_docker.py":
		require => Exec['check-docker-plugin'],
		owner => nagios,
		group => nagios,
		mode => 0755
	}
}
