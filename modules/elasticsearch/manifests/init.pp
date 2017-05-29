class elasticsearch {
	notify { '[elasticsearch] Setting up Elasticsearch repo and installing': withpath => false }

	$elasticsearch_repo_content = "
[elasticsearch-5.x]
name=Elasticsearch repository for 5.x packages
baseurl=https://artifacts.elastic.co/packages/5.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
"

	exec { 'GPG-KEY-elasticsearch':
		command => 'rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch',
		path => '/bin',
		unless => 'rpm -qi gpg-pubkey-* | grep -q Elasticsearch'
	}

	file { '/etc/yum.repos.d/elasticsearch.repo':
		require => Exec['GPG-KEY-elasticsearch'],
		ensure => file,
		content => "$elasticsearch_repo_content"
	}

	package { 'elasticsearch':
		require => File['/etc/yum.repos.d/elasticsearch.repo'],
		ensure => installed,
		allow_virtual => false
	}
}
