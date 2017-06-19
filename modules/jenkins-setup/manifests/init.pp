class jenkins-setup {
	notify { '[jenkins-setup] Setting up Jenkins repo and installing': withpath => false }

	$jenkins_repo_content = "
[jenkins]
name=Jenkins-stable
baseurl=http://pkg.jenkins.io/redhat-stable
gpgcheck=1
"

	package { 'java-1.8.0-openjdk':
		ensure => installed,
		allow_virtual => false
	}

	file { '/etc/yum.repos.d/jenkins.repo':
		require => Package['java-1.8.0-openjdk'],
		ensure => file,
		content => "$jenkins_repo_content"
	}

	exec { 'jenkins-repo-key':
		require => File['/etc/yum.repos.d/jenkins.repo'],
		path => '/usr/bin',
		command => 'rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key',
		unless => 'rpm -qi gpg-pubkey-* | grep -q kkawaguchi@cloudbees.com'
	}

	package { 'jenkins':
		require => Exec['jenkins-repo-key'],
		ensure => installed,
		allow_virtual => false
	}

	file { '/var/lib/jenkins/jenkins.install.InstallUtil.lastExecVersion':
		require => Package['jenkins'],
		content => "2.0",
		owner => jenkins,
		group => jenkins
	}

	service { 'jenkins':
		require => File['/var/lib/jenkins/jenkins.install.InstallUtil.lastExecVersion'],
		enable => true,
		ensure => running
	}

	package { 'curl':
		require => Service['jenkins'],
		ensure => installed,
		allow_virtual => false
	}

	exec { 'jenkins-cli':
		require => Package['curl'],
		path => '/bin',
		command => 'curl localhost:8080/jnlpJars/jenkins-cli.jar -o /usr/local/share/applications/jenkins-cli.jar',
		unless => 'test -f /usr/local/share/applications/jenkins-cli.jar'
	}

	exec { 'jenkins-cli-plugin-artifactory':
		require => Exec['jenkins-cli'],
		path => '/bin',
		command => 'java -jar /usr/local/share/applications/jenkins-cli.jar -s http://localhost:8080 -auth admin:`cat ~jenkins/secrets/initialAdminPassword` install-plugin artifactory',
		unless => 'java -jar /usr/local/share/applications/jenkins-cli.jar -s http://localhost:8080 -auth admin:`cat ~jenkins/secrets/initialAdminPassword` list-plugins | grep -q artifactory'
	}

	exec { 'jenkins-cli-plugin-pipeline':
		require => Exec['jenkins-cli-plugin-artifactory'],
		path => '/bin',
		command => 'java -jar /usr/local/share/applications/jenkins-cli.jar -s http://localhost:8080 -auth admin:`cat ~jenkins/secrets/initialAdminPassword` install-plugin build-pipeline-plugin',
		unless => 'java -jar /usr/local/share/applications/jenkins-cli.jar -s http://localhost:8080 -auth admin:`cat ~jenkins/secrets/initialAdminPassword` list-plugins | grep -q build-pipeline-plugin',
		notify => Exec['jenkins-restart']
	}

	exec { 'jenkins-restart':
		path => '/bin',
		command => 'systemctl restart jenkins',
		refreshonly => true
	}

	file { '/var/tmp/jenkins-config':
		require => Service['jenkins'],
		ensure => directory,
		notify => Exec['load-jenkins-config-pull']
	}

	package { 'git':
		ensure => installed,
		allow_virtual => false
	}

	exec { 'load-jenkins-config-pull':
		require => Package['git'],
		cwd => '/var/tmp/jenkins-config',
		path => '/usr/bin',
		command => 'git clone https://github.com/EthanWaldman/jenkins-config.git .',
		notify => Exec['load-jenkins-config-runscript'],
		refreshonly => true
	}

	exec { 'load-jenkins-config-runscript':
		cwd => '/var/tmp/jenkins-config',
		path => ['/bin','/usr/bin'],
		command => 'bash ./create_jenkins_items.sh',
		notify => Exec['reveal-initial-password'],
		refreshonly => true
	}

	exec { 'reveal-initial-password':
		require => Service['jenkins'],
		path => '/bin',
		command => "echo Jenkins initial password: `cat /var/lib/jenkins/secrets/initialAdminPassword`",
		logoutput => true,
		refreshonly => true
	}
}
