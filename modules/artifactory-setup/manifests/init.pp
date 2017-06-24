class artifactory-setup {
	notify { '[artifactory-setup] Setting up Artifactory repo and installing': withpath => false }

	$artifactory_repo_content = "
[bintray--jfrog-artifactory-rpms]
name=bintray--jfrog-artifactory-rpms
baseurl=http://jfrog.bintray.com/artifactory-rpms
gpgcheck=0
repo_gpgcheck=0
enabled=1
"

	file { '/etc/yum.repos.d/bintray-jfrog-artifactory-rpms.repo':
		ensure => file,
		content => "$artifactory_repo_content"
	}

	package { 'jfrog-artifactory-oss':
		require => File['/etc/yum.repos.d/bintray-jfrog-artifactory-rpms.repo'],
		ensure => installed,
		allow_virtual => false
	}

	service { 'artifactory':
		require => Package['jfrog-artifactory-oss'],
		enable => true,
		ensure => running
	}
}
