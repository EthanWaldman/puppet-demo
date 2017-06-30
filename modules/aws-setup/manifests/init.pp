class aws-setup {
	notify { '[aws-setup] Setting up AWS CLI and ECS CLI': withpath => false }

	package { 'python34':
		ensure => installed,
		allow_virtual => false
	}

	exec { 'python-pip-install':
		require => Package['python34'],
		path => '/usr/bin',
		command => 'python3 get-pip.py',
		unless => 'which pip'
	}
}
