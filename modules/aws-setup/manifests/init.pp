class aws-setup {
	notify { '[aws-setup] Setting up AWS CLI and ECS CLI': withpath => false }

	$aws_config_file = "
[default]
region = us-west-2
output = json
"

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
#		command => 'pip install awscli --upgrade --user && cp ~/.local/bin/aws /usr/local/bin && chmod +rx /usr/local/bin/aws',
		command => 'pip install awscli --upgrade --user',
		unless => 'which aws',
		user => jenkins
	}

	file { '/var/lib/jenkins/.aws':
		require => Exec['install-aws-cli'],
		ensure => directory,
		owner => jenkins,
		group => jenkins,
		mode => '0755'
	}

	file { '/var/lib/jenkins/.aws/config':
		require => File['/var/lib/jenkins/.aws'],
		ensure => file,
		content => "$aws_config_file",
		owner => jenkins,
		group => jenkins,
		mode => '0600'
	}
}
