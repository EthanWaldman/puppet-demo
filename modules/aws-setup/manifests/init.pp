class aws-setup {
	notify { '[aws-setup] Setting up AWS CLI and ECS CLI': withpath => false }

	package { 'python34':
		ensure => installed,
		allow_virtual => false
	}

	exec { 'python-pip-install':
		require => Package['python34'],
		path => '/usr/bin',
		cwd => '/var/tmp',
		command => 'curl -O https://bootstrap.pypa.io/get-pip.py; python3 get-pip.py',
		unless => 'which pip'
	}

	exec { 'install-aws-cli':
		require => Exec['python-pip-install'],
		path => ['/bin','/usr/local/bin'],
		command => 'pip install awscli --upgrade --user && cp ~/.local/bin/aws /usr/local/bin && chmod +rx /usr/local/bin/aws',
		unless => 'which aws'
	}
}
