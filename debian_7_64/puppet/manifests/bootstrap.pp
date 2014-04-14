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

class python {
	package {
		['python-software-properties', 'python-pip', 
			'libpq-dev', 'python-dev', 'libldap2-dev', 
			'libsasl2-dev', 'libssl-dev', 'libxml2-dev',
			'libxslt-dev']:
		ensure => ['installed']
	}

	exec {
    	'virtualenv':
      	command => '/usr/bin/sudo pip install virtualenv==1.10',
      	require => Package['python-pip'],
  	}

  	exec {
    	'virtualenvwrapper':
      	command => '/usr/bin/sudo pip install virtualenvwrapper',
      	require => Package['python-pip'],
  	}

  	$virtualenv_dir = '/home/vagrant/_virtualenv'
  	file {
  		'/home/vagrant/_virtualenv':
  		ensure => 'directory',
  		owner => 'vagrant',
  		group => 'vagrant'
  	}

  	file_line { 'export_workon_home':
		path => '/home/vagrant/.profile',
   		line => "export WORKON_HOME=${virtualenv_dir}",
   		require => [Exec['virtualenvwrapper']]
	}

	file_line { 'source_virtualevnwrapper':
		path => '/home/vagrant/.bashrc',
   		line => "source /usr/local/bin/virtualenvwrapper.sh",
   		require => [Exec['virtualenvwrapper']]
	}

	file_line { 'virtualenv-home':
		path => '/home/vagrant/.profile',
   		line => "export VIRTUALENVS_HOME=${virtualenv_dir}",
   		require => [Exec['virtualenv']]
	}
}

class tools {
	package {
		['terminator', 'xfe', 'wireshark', 'gettext', 'curl']:
		ensure => ['installed'],
		require => [Class['gui']]
	}

	package {
		['bcompare']:
		ensure => ['installed'],
		require => Class['pointsrepo']
	}
}

class pointsrepo {
	file_line { 'points_repo':
		path => '/etc/apt/sources.list',
   		line => 'deb http://tor-ops1.points.com/apt precise main'
	}

	exec { 'update':
		command => '/usr/bin/sudo apt-get -y update',
		require => [File_line['points_repo']]
	}

	file { '/etc/apt/trusted.gpg.d/points-repo.gpg':
		ensure => ['file', 'present'],
		source => '/vagrant/files/points-repo.gpg'
	}
}

class databases {
	package {
		['postgresql', 'pgadmin3']:
		ensure => ['installed'],
		require => [Class['gui']]
	}

	package {
		["points-couchdb"]:
		ensure => ['installed'],
		require => Class['pointsrepo']
	}

	exec {
    	'couchdb-install':
      	command => '/usr/bin/sudo pip install CouchDB',
      	require => Package['python-pip', 'points-couchdb']
  	}

  	file { '/local/opt/points/couchdb/etc/couchdb/local.d/local.ini':
  		source => '/vagrant/files/couchdb/local.ini',
  		ensure => ['present'],
  		notify => Service['couchdb'],
  		require => Package['points-couchdb']
  	}

  	service { 'couchdb':
 		ensure  => 'running',
    	enable  => 'true',
    	require => Package['points-couchdb']
	}
}

class vcs {
	apt::ppa {'ppa:mercurial-ppa/releases':}
	
	package {
		["mercurial"]:
		ensure => ['installed'],
		require => Apt::Ppa['ppa:mercurial-ppa/releases']
	}

	file { '/home/vagrant/.hgrc':
		ensure => ['file', 'present'],
		source => '/vagrant/files/.hgrc',
		replace => false
	}

	apt::ppa {'ppa:tortoisehg-ppa/releases':}

	package {
		['tortoisehg']:
		ensure => ['installed'],
		require => Apt::Ppa['ppa:tortoisehg-ppa/releases']
	}

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

class javainstall {
	file_line { 'java_home_env':
		path => '/home/vagrant/.profile',
   		line => 'export JAVA_HOME=/opt/java/jdk1.7.0_45',
   		require => [Class['java']]
	}
	file_line { 'java_path_env':
		path => '/home/vagrant/.profile',
   		line => 'export PATH=$PATH:$JAVA_HOME/bin',
   		require => [Class['java']]
	}
}

class pycharm {
	$pycharm_version = '3.1.1'
	$pycharm = "pycharm-professional-${pycharm_version}"
	exec { 'download_pycharm':
		command => "/usr/bin/sudo /usr/bin/wget --timeout=1200 -P tmp/ http://download.jetbrains.com/python/${pycharm}.tar.gz",
		require => [Class['javainstall']],
		unless => "/bin/ls tmp | /bin/grep ${pycharm}.tar.gz"
	}

	exec { 'install-pycharm':
		command => "/usr/bin/sudo /bin/tar -xzf tmp/${pycharm}.tar.gz -C /opt",
		require => [Class['javainstall'], Exec['download_pycharm']],
		unless => "/bin/ls /opt | /bin/grep pycharm-${pycharm_version}"
	}

	file_line { 'pycharm_path_env':
		path => '/home/vagrant/.profile',
		match => '^export PATH=\$PATH:/opt/pycharm.*$',
   		line => "export PATH=\$PATH:/opt/pycharm-${pycharm_version}/bin",
   		require => [Exec['install-pycharm']]
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

class javascript-testing {
	package {
		['npm', 'g++']:
		ensure => ['installed']
	}
}

include gui
include virtualbox
include timezone
include editors
include python
include tools
include databases
include vcs
include browsers
include stdlib
include pointsrepo
include java
include javainstall
include pycharm
include javascript-testing