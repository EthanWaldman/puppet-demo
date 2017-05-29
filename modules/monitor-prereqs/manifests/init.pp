class monitor-prereqs {
	notify { '[monitor-prereqs] Installing prerequisite packages for monitoring functions': withpath => false }

	package { 'epel-release':
		ensure => installed,
		allow_virtual => false
	}
	package { 'git':
		ensure => installed,
		allow_virtual => false
	}
	package { 'jq':
		ensure => installed,
		allow_virtual => false
	}
	package { 'python34':
		ensure => installed,
		allow_virtual => false
	}
}
