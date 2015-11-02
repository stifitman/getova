load "#{Rails.root}/db/xml_to_company.rb"
require "j2o"

def insert_sparql_for_europass
  file = File.open("#{Rails.root}/db/ep2resume.sparql", "rb")
  e2r = file.read
  file.close

  file = File.open("#{Rails.root}/db/resume2ep.sparql", "rb")
  r2e = file.read
  file.close

  cv1json = cv1json.to_s.force_encoding("UTF-8")

  IndividualFormat.create(name: 'resume', baseToFormat: e2r, formatToBase: r2e)
  IndividualFormat.create(name: 'xml', baseToFormat: '', formatToBase: '')
  IndividualFormat.create(name: 'rdf', baseToFormat: '', formatToBase: '')
  IndividualFormat.create(name: 'jsonld', baseToFormat: '', formatToBase: '')
  IndividualFormat.create(name: 'json', baseToFormat: '', formatToBase: '')

end


def create_some_individuals
  #add betty
  file = File.open("#{Rails.root}/db/cv1.json", "rb")
  cv1json = file.read
  file.close

  cv1 = Individual.create(name: 'betty')
  jsonFormat = IndividualFormat.find_by :name => 'json'
  Representation.create(individual_id: cv1.id, format_id: jsonFormat.id , content: cv1json)

  #generate some data
  gen =  TestDataCreator.new
  25.times do |i|
    cv = Individual.create(name: "Generated #{i}")
    gen.generate
    Representation.create(individual_id: cv.id, format_id: jsonFormat.id , content: gen.json)
  end

end

def insert_company_data_tifd
  store = StoreXml.new
  store.run("#{Rails.root}/db/WAFData.xml")
end

def insert_company_data_led

  puts "CONNECTING to #{ENV['elastic_search_ip']}"
  @es_client = Elasticsearch::Client.new host: ENV['elastic_search_ip'], transport_options: {
    request: { timeout: 100 }
  }

  companies = Hash.new
  Dir["#{Rails.root}/db/led_data/*"].each do |f|
    file = File.open(f.to_s, "rb")
    data = file.read
    company_name = File.basename(f,".*")
    puts company_name
    companies[company_name] = Hash.new unless companies.has_key? company_name
    companies[company_name][:name] = company_name.to_s.force_encoding("UTF-8")

    ext = File.extname(f).split(".").last
    data = data.to_s.force_encoding("UTF-8")
    jsonld =  getJsonld(data)
    puts "json ld"
    puts jsonld.to_json

    if ext == "usdl"
      companies[company_name][:usdl] = data.to_s.force_encoding("UTF-8")
      companies[company_name][:jsonld] = "#{jsonld.to_json}"
      #@es_client.index  index: 'companies', type: 'usdl', id: company_name,   body: jsonld2json(jsonld)
    else
      companies[company_name][:content] = data.to_s.force_encoding("UTF-8")
      companies[company_name][:json] = "#{jsonld.to_json}"
      puts "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
      jsonized = jsonld2json jsonld
      puts "publishing #{jsonized}"
      puts @es_client.index  index: 'companies', type: 'rdf', id: company_name,   body: jsonized
      puts "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
    end
    file.close
  end

  companies.each do |k, v|
    puts "adding #{k} company"
    Company.create v
  end
end


def jsonld2json(jsonld)
  jsonld.delete '@context'

  plain = Hash.new
  jsonld.each do |k,v|
    key = k
    match_result = k.match('(:)(\w+)')
    puts "matchresult: #{match_result}"
    key = match_result[2].to_s unless match_result.nil?

    plain[key] = v.strip unless v.class == Array
  end
  puts "####################################################################################################"
  puts plain
  puts "####################################################################################################"
  return plain
end

def getJsonld(rdf)
  input = RDF::Graph.new << RDF::Reader.for(:ntriples).new(rdf)
  context = JSON.parse %({
    "@context": {
        "gr": "http://purl.org/goodrelations/v1#",
        "s": "http://schema.org/address",
        "v": "http://www.w3.org/2006/vcard/ns#",
        "l": "http://www.linked-usdl.org/ns/usdl-core#",
        "foaf": "http://xmlns.com/foaf/0.1/",
        "c": "http://fitman.sti2.at/company/"
   }
   })
   compacted = nil
   JSON::LD::API::fromRdf(input) do |expanded|
     compacted = JSON::LD::API.compact(expanded, context['@context'])
   end

   compacted
end

insert_sparql_for_europass
create_some_individuals
insert_company_data_tifd
begin
  insert_company_data_led
rescue => e
  puts "problems with elasticsearch? Did you start the server?"
  puts e
end

