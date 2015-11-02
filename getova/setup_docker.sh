export JAVA_HOME=/usr/lib/jvm/java-8-oracle/ 
export elastic_search_ip=192.168.59.103  
export rails_server_ip=192.168.59.103:3000 
cd ~/data_extraction && bundle && rspec 
cd ~/webinterface i&&  rake db:reset && rails s 


