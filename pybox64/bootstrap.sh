#!/usr/bin/env bash
echo Provisioning started...........

sudo apt-get update

sudo apt-get -y install lxde
sudo apt-get -y install virtualbox-ose-guest-utils virtualbox-ose-guest-x11 virtualbox-ose-guest-dkms
sudo apt-get -y install xinit

#update time zone to EST
echo "US/Eastern" | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata 

sudo apt-get -y remove dictionaries-common
sudo apt-get -y install python-software-properties
sudo apt-get -y install terminator
sudo apt-get -y install vim
sudo apt-get -y install xfe
sudo apt-get -y install wireshark

sudo apt-get -y install postgresql
sudo apt-get -y install pgadmin3

sudo apt-add-repository -y ppa:mercurial-ppa/releases
sudo apt-get update
sudo apt-get -y install mercurial
cp /vagrant/.hgrc ~/.hgrc
sudo apt-add-repository -y ppa:tortoisehg-ppa/releases
sudo apt-get update
sudo apt-get -y install tortoisehg

sudo apt-add-repository -y ppa:webupd8team/sublime-text-2
sudo apt-get update
sudo apt-get -y install sublime-text

sudo apt-get -y install python-pip
pip install virtualenv==1.10
pip install virtualenvwrapper

sudo add-apt-repository -y ppa:lubuntu-desktop/ppa
sudo apt-get update
sudo apt-get -y install lubuntu-software-center

sudo apt-get -y install firefox

sudo apt-get -y install libnspr4-0d
sudo apt-get -y install libcurl3

sudo wget -P tmp/ https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BF4B41FF5-1D88-62B0-B58A-AACF5726970B%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i tmp/google-chrome-stable_current_amd64.deb
sudo apt-get -f install

sudo pip install CouchDB
echo -e '[query_servers]\npython=couchpy' | sudo tee -a /local/opt/points/couchdb/etc/couchdb/local.d/local.ini
sudo service couchdb start

sudo add-apt-repository -y 'deb http://tor-ops1.points.com/apt precise main'
sudo cp /vagrant/points-repo.gpg /etc/apt/trusted.gpg.d/points-repo.gpg
sudo apt-get update
sudo apt-get -y install points-couchdb
sudo apt-get -y install bcompare

sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
sudo apt-get -y purge openjdk*
#sudo apt-get -y install oracle-jdk7-installer
#sudo update-java-alternatives -s java-7-oracle
sudo apt-get -y install oracle-java7-installer

sudo apt-get -y install oracle-java7-set-default

sudo wget -P tmp/ -x http://download.jetbrains.com/python/pycharm-community-3.0.2.tar.gz
sudo tar -xzvf tmp/download.jetbrains.com/python/pycharm-community-3.0.2.tar.gz -C /opthg a

mkdir ~/virtualenvs

startx