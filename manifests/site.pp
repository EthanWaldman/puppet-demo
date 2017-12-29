node 'demo_mon' {
	include monitor-prereqs
	include elasticsearch-setup
	include kibana-setup
	include nagios-setup
	include grafana-setup
}

node 'demo_docker' {
	include docker-setup
}

node 'demo_build' {
	include jenkins-setup
	include artifactory-setup
	include aws-setup
}
