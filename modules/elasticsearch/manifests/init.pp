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

	package { 'java-1.8.0-openjdk':
		ensure => installed,
		allow_virtual => false
	}

	exec { 'GPG-KEY-elasticsearch':
		require => Package['java-1.8.0-openjdk'],
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

	exec { 'elasticsearch-heap':
		require => Package['elasticsearch'],
		path => '/bin',
		command => 'sed -E -i "s/^(-Xm.).*g/\11g/" /etc/elasticsearch/jvm.options',
		unless => 'cat /etc/elasticsearch/jvm.options | grep -q "^\-Xmx1g"'
	}

	file { 'es-top-dir':
		require => Package['elasticsearch'],
		path => '/es',
		ensure => directory,
		owner => elasticsearch,
		group => elasticsearch
	}
	file { 'es-data-dir':
		require => File['es-top-dir'],
		path => '/es/data',
		ensure => directory,
		owner => elasticsearch,
		group => elasticsearch
	}
	file { 'es-logs-dir':
		require => File['es-top-dir'],
		path => '/es/logs',
		ensure => directory,
		owner => elasticsearch,
		group => elasticsearch
	}

	exec { 'elasticsearch-config-path-data':
		require => File['es-data-dir'],
		path => '/bin',
		command => 'sed -E -i "s|^#path.data: .*$|path.data: /es/data|" /etc/elasticsearch/elasticsearch.yml',
		unless => 'cat /etc/elasticsearch/elasticsearch.yml | grep -q "^"path.data:"'
	} ->
	exec { 'elasticsearch-config-path-logs':
		require => File['es-logs-dir'],
		path => '/bin',
		command => 'sed -E -i "s|^#path.logs: .*$|path.logs: /es/logs|" /etc/elasticsearch/elasticsearch.yml',
		unless => 'cat /etc/elasticsearch/elasticsearch.yml | grep -q "^"path.logs:"'
	} ->
	exec { 'elasticsearch-config-network-host':
		require => Package['elasticsearch'],
		path => '/bin',
		command => 'sed -E -i "s/^#network.host: .*$/network.host: 0.0.0.0/" /etc/elasticsearch/elasticsearch.yml',
		unless => 'cat /etc/elasticsearch/elasticsearch.yml | grep -q "^"network.host:"'
	} ->
	exec { 'elasticsearch-config-http-port':
		require => Package['elasticsearch'],
		path => '/bin',
		command => 'sed -E -i "s/^#http.port: .*$/http.port: 9200/" /etc/elasticsearch/elasticsearch.yml',
		unless => 'cat /etc/elasticsearch/elasticsearch.yml | grep -q "^"http.port:"'
	}

	service { 'elasticsearch':
		require => Exec['elasticsearch-config-http-port'],
		ensure => running
	}
}
