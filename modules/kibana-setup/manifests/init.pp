class kibana-setup {
	notify { '[kibana-setup] Setting up Kibana repo and installing': withpath => false }

	$kibana_repo_content = "
[kibana-5.x]
name=Kibana repository for 5.x packages
baseurl=https://artifacts.elastic.co/packages/5.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
"

	exec { 'GPG-KEY-elasticsearch-for-Kibana':
		command => 'rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch',
		path => '/bin',
		unless => 'rpm -qi gpg-pubkey-* | grep -q Elasticsearch'
	}

	file { '/etc/yum.repos.d/kibana.repo':
		require => Exec['GPG-KEY-elasticsearch-for-Kibana'],
		ensure => file,
		content => "$kibana_repo_content"
	}

	package { 'kibana':
		require => File['/etc/yum.repos.d/kibana.repo'],
		ensure => installed,
		allow_virtual => false
	}

	exec { 'kibana-config-server-host':
		require => Package['kibana'],
		path => '/bin',
		command => 'sed -E -i "s/^#server.host: .*$/server.host: 0.0.0.0/" /etc/kibana/kibana.yml',
		unless => 'cat /etc/kibana/kibana.yml | grep -q "^"server.host:"'
	} ->
	exec { 'kibana-config-server-port':
		require => Package['kibana'],
		path => '/bin',
		command => 'sed -E -i "s/^#server.port: .*$/server.port: 5602/" /etc/kibana/kibana.yml',
		unless => 'cat /etc/kibana/kibana.yml | grep -q "^"server.port:"'
	}

	service { 'kibana':
		require => Exec['kibana-config-server-port'],
		ensure => running
	}
}
