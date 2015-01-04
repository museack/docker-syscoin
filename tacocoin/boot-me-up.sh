#! /usr/bin/env bash
set -e


# Config


# https://gist.github.com/dergachev/8441335
# If host is running squid-deb-proxy on port 8000, populate /etc/apt/apt.conf.d/30proxy
# By default, squid-deb-proxy 403s unknown sources, so apt shouldn't proxy ppa.launchpad.net
route -n | awk '/^0.0.0.0/ {print $2}' > /tmp/host_ip.txt
echo "HEAD /" | nc `cat /tmp/host_ip.txt` 8000 | grep squid-deb-proxy \
	&& (echo "Acquire::http::Proxy \"http://$(cat /tmp/host_ip.txt):8000\";" > /etc/apt/apt.conf.d/30proxy) \
	&& (echo "Acquire::http::Proxy::ppa.launchpad.net DIRECT;" >> /etc/apt/apt.conf.d/30proxy) \
	|| echo "No squid-deb-proxy detected on docker host"


# Ensure package list is up to date.
apt-get update

# Install runtime dependencies.
#apt-get install -y  

# Install build dependencies.
apt-get install -y libtool wget bsdmainutils autoconf makepasswd libqrencode-dev libcurl4-openssl-dev automake make libdb5.1++-dev ntp git build-essential libssl-dev libdb5.1-dev libboost-all-dev 

# Prepare building
mkdir -p /src
#mv /etc/service/sshd/run /etc/service/sshd/stop
touch /etc/service/sshd/down

##
#add the mazacoin user
groupadd --gid 2211 mazamulti
adduser --disabled-password --gecos "mazamulti" --uid 2211 --gid 2211 mazamulti
##
#mkdir /home/mazamulti/.tacocoin
#cp -v /tmp/mazacoin.conf /home/maza/.mazacoin
#mv -v /tmp/cron-mazacoind /etc/cron.d/cron-mazacoind
#chown root.root /etc/cron.d/cron-mazacoind
#chmod 750 /etc/cron.d/cron-mazacoind
#mv -v /tmp/backupwallet.sh /usr/local/bin/backupwallet.sh
#chown root.root /usr/local/bin/backupwallet.sh
#chmod 755 /usr/local/bin/backupwallet.sh
## Download, compile and install mazacoind.
#touch /home/maza/.mazacoin/.firstrun
mkdir /etc/service/coind
cd /src
git clone https://github.com/Tacocoin/tacocoin
cd "tacocoin"
make -f makefile.unix install
mv /run /etc/service/coind
chmod 600 /home/maza/.tacocoin/tacocoin.conf 
chmod 700 /etc/service/tacocoind/run

# Clean up
#apt-get remove -y wget
apt-get autoremove -y
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
