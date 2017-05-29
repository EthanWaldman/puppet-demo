node 'centos7_mon' {
	include monitor-prereqs
	include elasticsearch-setup
	include kibana-setup
	include nagios-setup
}
