stage { 'first': 
      before => Stage['main']
}

stage { 'last': }
Stage['main'] -> Stage['last']

class { 'update':
	stage => first
}

class { 'monitor':
	stage => last
}

class update {
	exec { 
		'apt-update':
    	command => '/usr/bin/apt-get -y update'
	}
}

class { 'apt':
	always_apt_update => true
}

class gui {
	package{
		['lxde', 'xinit']:
		ensure => ['latest']
	}
}

class virtualbox {
	package {
		['virtualbox-ose-guest-utils', 'virtualbox-ose-guest-x11', 'virtualbox-ose-guest-dkms']:
		ensure => ["latest"]
	}
}

class { 'timezone':
	timezone => 'US/Eastern'
}

class editors {
	package {
		['vim', 'geany']:
		ensure => ['latest'] 
	}

  	apt::ppa {'ppa:webupd8team/sublime-text-2':}

  	package { 
    	[ 'sublime-text' ]:
      	ensure => ['installed'],
      	require => [Class['gui'], Apt::Ppa['ppa:webupd8team/sublime-text-2']]
  	}
}


class tools {
	package {
		['terminator', 'xfe', 'wireshark', 'gettext', 'curl']:
		ensure => ['installed'],
		require => [Class['gui']]
	}
}


class databases {
	package {
		['postgresql', 'pgadmin3']:
		ensure => ['installed'],
		require => [Class['gui']]
	}
}

class vcs {

	package {
		['git-core']:
		ensure => ['installed']
	}
}

class browsers {
	package {
		['firefox']:
		ensure => ['installed'],
		require => [Class['gui']]
	}

	package {
		['libnspr4-0d', 'libcurl3']:
		ensure => ['installed']
	}
 

	exec{
		'download-chrome':
		command => '/usr/bin/sudo wget -P tmp/ https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BF4B41FF5-1D88-62B0-B58A-AACF5726970B%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers/linux/direct/google-chrome-stable_current_amd64.deb',
		unless => '/usr/bin/dpkg -l | /bin/grep google-chrome-stable'
	}
    
	exec{
		'install-chrome':
		command => '/usr/bin/sudo dpkg -i tmp/google-chrome-stable_current_amd64.deb && /usr/bin/sudo apt-get -f install',
		require => [Package['libnspr4-0d', 'libcurl3'], Exec['download-chrome'], Class['gui']],
		unless => '/usr/bin/dpkg -l | /bin/grep google-chrome-stable'
	}
}

class monitor {
	file_line { 'adjust_monitors':
		path => '/home/vagrant/.profile',
		match => '^/usr/bin/xrandr --output.*$',
   		line => '/usr/bin/xrandr --output VBOX1 --right-of VBOX0',
   		require => [Class['gui']]
	}
}

include gui
include virtualbox
include timezone
include editors
include tools
include databases
include vcs
include browsers
include stdlib