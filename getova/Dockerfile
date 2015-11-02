FROM phusion/baseimage:latest

# Update and install needed packages
RUN apt-get -y update
RUN apt-get -y dist-upgrade
# capybara-webkit needs: qt5-default libqt5webkit5-dev
# for cronjobs we need: cron
# paperclip needs: imagemagick
# wkhtmltopdf needs: openssl build-essential xorg libssl-dev
# pg needs: libpq-dev
# rvm needs: gawk libreadline6-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
# apt-get install libcurl4-gnutls-dev necessary for patron gem to run
RUN apt-get -y install curl git qt5-default libqt5webkit5-dev imagemagick cron openssl build-essential xorg libssl-dev libpq-dev gawk libreadline6-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
RUN apt-get -y install software-properties-common python-software-properties libcurl4-gnutls-dev

# Set timezone
RUN echo "Europe/Vienna" | tee /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

# Create user 'getova'
RUN /bin/bash -l -c "adduser --disabled-password --gecos '' getova"

# Install RVM and Ruby
RUN su -l getova -c  "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3"
RUN su -l getova -c  "\curl -sSL https://get.rvm.io | bash -s -- --version 1.26.11"
RUN su -l getova -c "echo 'source /home/getova/.rvm/scripts/rvm' >> /home/getova/.bashrc"
RUN su -l getova -c "rvm install 2.2.2"
RUN su -l getova -c "rvm use 2.2.2@global --create --default"
RUN su -l getova -c "gem install bundler"
RUN su -l getova -c "gem install execjs"

# Install Java for the clustering
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java8-installer

# Add required folders
COPY webinterface /home/getova/webinterface
COPY json2ontology /home/getova/json2ontology
COPY data_extraction /home/getova/data_extraction
COPY setup_docker.sh /home/getova/setup_docker.sh
COPY setup_docker_noboot2docker.sh /home/getova/setup_docker_noboot2docker.sh

RUN chown -R getova:getova /home/getova/**

# Setup stuff 
RUN su -l getova -c "cd ~/data_extraction && git init"
RUN su -l getova -c "cd ~/data_extraction && rake install"
RUN su -l getova -c "cd ~/json2ontology && git init"
RUN su -l getova -c "cd ~/json2ontology && rake install"

RUN su -l getova -c "cd ~/webinterface && bundle update"
RUN su -l getova -c "cd ~/webinterface && bundle install"
RUN su -l getova -c "cd ~/webinterface && bundle show j2o"
RUN su -l getova -c "gem list -d"
#RUN su -l getova -c "gem install j2o"
RUN su -l getova -c "cd ~/webinterface && bundle exec rake db:create"
RUN su -l getova -c "cd ~/webinterface && bundle exec rake db:migrate"

# Run rails servers
#RUN su -l getova -c "cd ~/GeToVa && rails s"

