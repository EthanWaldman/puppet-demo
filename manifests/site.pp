node 'centos7_mon' {
	include monitor-prereqs
	include elasticsearch-setup
	include kibana-setup
	include nagios-setup
	include grafana-setup
}

node 'centos7_docker1' {
	include docker-setup
}

node 'centos7_build' {
	include jenkins-setup
	include artifactory-setup
}
