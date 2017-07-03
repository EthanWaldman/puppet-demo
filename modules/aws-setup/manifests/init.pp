class aws-setup {
	notify { '[aws-setup] Setting up AWS CLI and ECS CLI': withpath => false }

	$aws_config_file = "
[default]
region = us-west-2
output = json
"

	$aws_credentials_file = "
[default]
aws_secret_access_key = farMNOu3UTpkXrCBhIRTnCf34ZA8AT5YyZcEcfXT
aws_access_key_id = AKIAJKH6D4QF3Q4TP6XA
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
		command => 'pip install awscli --upgrade --user && cp ~/.local/bin/aws /usr/local/bin && chmod +rx /usr/local/bin/aws',
		unless => 'which aws'
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
	file { '/var/lib/jenkins/.aws/credentials':
		require => File['/var/lib/jenkins/.aws'],
		ensure => file,
		content => "$aws_credentials_file",
		owner => jenkins,
		group => jenkins,
		mode => '0600'
	}
}
