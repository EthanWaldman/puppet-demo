class aws-setup {
	notify { '[aws-setup] Setting up AWS CLI and ECS CLI': withpath => false }

	$aws_region = "us-west-2"
	$aws_config_file = "
[default]
region = $aws_region
output = json
"
	$aws_credfilepath = "/var/lib/jenkins/.aws/credentials"
	$ecs_cluster = "ew-ecs-cluster"

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
	file { "$aws_credfilepath":
		require => File['/var/lib/jenkins/.aws'],
		ensure => file,
		source => "file:/vagrant/credentials",
		owner => jenkins,
		group => jenkins,
		mode => '0600'
	}

	exec { 'install-ecs-cli':
		require => File["$aws_credfilepath"],
		path => ['/usr/bin','/usr/local/bin'],
		command => 'curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest; chmod +rx /usr/local/bin/ecs-cli',
		notify => Exec['configure-ecs-cli'],
		unless => 'which ecs-cli'
	}

	exec { 'configure-ecs-cli':
		path => ['/usr/bin','/usr/local/bin'],
		user => jenkins,
		command => "ecs-cli configure -region $aws_region --access-key=`cat $aws_credfilepath | grep access_key_id | tr -d ' ' | cut -d= -f2` --secret-key=`cat $aws_credfilepath | grep secret_access_key | tr -d ' ' | cut -d= -f2` --cluster $ecs_cluster",
		logoutput => true,
		refreshonly => true
	}
}
