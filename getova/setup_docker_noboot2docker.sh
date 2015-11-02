
export JAVA_HOME=/usr/lib/jvm/java-8-oracle/ 
export elastic_search_ip=localhost
export rails_server_ip=localhost:3000 
cd ~/data_extraction && bundle && rspec 
cd ~/webinterface i&&  rake db:reset && rails s 
