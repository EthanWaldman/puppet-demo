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
}
