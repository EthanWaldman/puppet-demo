class docker-setup {
	notify { '[docker-setup] Installing Docker and configuring for remote API accss': withpath => false }

	package { 'docker':
		ensure => installed,
		allow_virtual => false
	}

        exec { 'docker-enable-network-access':
                require => Package['docker'],
                path => '/bin',
                command => 'sed -E -i "s/^DOCKER_NETWORK_OPTIONS=.*$/DOCKER_NETWOR_OPTIONS=\"-H unix:///var/run/docker.sock -H tcp://0.0.0.0\"/" /etc/sysconfig/docker-network',
                unless => 'cat /etc/sysconfig/docker-network | grep -q tcp://0.0.0.0'
        }

	service { 'docker':
		require => Exec['docker-enable-network-access'],
		enable => true,
		ensure => running
	}
}
