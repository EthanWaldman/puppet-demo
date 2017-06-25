class grafana-setup {
	notify { '[grafana-setup] Installing Grafana and configuring': withpath => false }

	$grafana_url = "https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-4.2.0-1.x86_64.rpm"

	package { 'grafana':
		provider => rpm,
		source => "$grafana_url",
		ensure => installed,
		allow_virtual => false
	}

	service { 'grafana-server':
		require => Package['grafana'],
		enable => true,
		ensure => running
	}

	package { 'curl':
		require => Service['grafana-server'],
		ensure => installed,
		allow_virtual => false
	}

	file { '/var/tmp/grafana-config':
		require => Service['grafana-server'],
		ensure => directory,
		notify => Exec['load-grafana-config-pull']
	}

	exec { 'load-grafana-config-pull':
		require => File['/var/tmp/grafana-config'],
		cwd => '/var/tmp/grafana-config',
		path => '/usr/bin',
		command => 'git clone https://github.com/EthanWaldman/grafana-configs.git .',
		notify => Exec['load-grafana-config-runscript'],
		refreshonly => true
	}

	exec { 'load-grafana-config-runscript':
		cwd => '/var/tmp/grafana-config',
		path => ['/bin','/usr/bin'],
		command => 'bash ./create_grafana_items.sh',
		refreshonly => true
	}
}
