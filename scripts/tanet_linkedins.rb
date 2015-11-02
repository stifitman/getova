require 'restclient'
response =  RestClient.get "http://localhost:3000/scrape_linkedin",
  { :params =>  {'url' => "https://at.linkedin.com/in/ioantoma"}, :accept => :json}



puts response



response =  RestClient.get "http://fitman.sti2.at/scrape_linkedin",
  { :params =>  {'url' => "https://at.linkedin.com/in/ioantoma"}, :accept => :json}



puts response
