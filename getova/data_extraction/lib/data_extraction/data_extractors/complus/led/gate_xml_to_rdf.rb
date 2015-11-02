require 'json'
require 'nokogiri'
require 'open-uri'
require 'rdf'
require 'rdf/ntriples'
require 'sparql'
require 'pathname'
require 'elasticsearch'

class CompanyExtractor

  def cleanHtml(html)
    if html.respond_to? ('text') #is a nokogiri node
      html.text.chomp.gsub(/\s+/, " ")
    else
      html.gsub(%r{</?[^>]+?>}, '') # assume plain text:w
    end
  end

  #adds triples to the rdf graph
  def addTriple(subject,predicat,object)
    puts "Add triple #{subject} #{predicat} #{object}"
    if subject != nil and predicat != nil and object != nil
      @graph << [ subject, predicat, object]
    else
      puts "Tried to add nil tuple (but cancelled) : " + subject.to_s + " " + predicat.to_s + " " + object.to_s
    end
  end

  #adds triple to the rdf graph
  def addUSDL(subject,predicat,object)
    if subject != nil and predicat != nil and object != nil
      @graph_usdl << [ subject, predicat, object]
    else
      puts "Tried to add nil tuple to USDL (but cancelled) : " + subject.to_s + " " + predicat.to_s + " " + object.to_s
    end
  end

  def add_annotation(annotation, text)
    @annotations[annotation] = Array.new unless @annotations.has_key? annotation
    @annotations[annotation] << text.strip unless text.nil?
  end

  #############################################################
  # Extract the person data
  #############################################################
  def extractData()

    @es_client = Elasticsearch::Client.new host: 'http://192.168.59.103:9200/', log: true
    gr = RDF::Vocabulary.new("http://purl.org/goodrelations/v1#")
    s = RDF::Vocabulary.new("http://schema.org/address")
    v = RDF::Vocabulary.new("http://www.w3.org/2006/vcard/ns#")
    l = RDF::Vocabulary.new("http://www.linked-usdl.org/ns/usdl-core#")

    company = RDF::Node.new
    addTriple( company , RDF.type, @resume_cv.Company)
    addUSDL(company, RDF.type, gr.BusinessEntity)

    #  content = @doc.css('div').select{|document| document['id'] == "inhalt"}[0]
    company_name = extractAnnotation("name").first

    add_annotation("name", company_name)
    #  description = @doc.css('div').select{|description| description['id'] == "text"}[0]


    website = extractAnnotation("website").first
    streetAddress = extractAnnotation("streetAddress").first
    postal = extractAnnotation("postal").first
    locality = extractAnnotation("locality").first
    country = extractAnnotation("country").first
    phone = extractAnnotation("phone").first
    mail = extractAnnotation( "mail").first
    region = country

    extractAnnotation("product_categories").each do  |i|
      puts "i: #{i}"
      product = RDF::Node.new
      addUSDL(product, RDF.type, gr.ProductOrService)
      addUSDL(product, gr.name, i)
      addUSDL(product, gr.hasManufacturer, company)
      addTriple(company, @resume_cv.produces, i)
    end

    extractAnnotation("produces").each do  |i|
      puts "prodcat2 : #{i}"
      offering = RDF::Node.new
      addUSDL(offering, RDF.type, gr.Offering)
      addUSDL(company, gr.offers, offering)
      addUSDL(offering, gr.name , i)

      addTriple(company, @resume_cv.sells , i)
    end

    extractAnnotation("distr_category").each do  |i|
      puts "distcat : #{i}"
      addUSDL(company, gr.category, i)
      addTriple(company, @resume_cv.distribution_type, i)
    end

    extractAnnotation("distributes_for").each do  |i|
      puts "distfor : #{i}"
      addUSDL(company, @resume_cv.distribution_for, i)
      addTriple(company, @resume_cv.distribution_for, i)
    end

    extractAnnotation("provides").each do  |i|
      puts "provcat : #{i}"
      offering = RDF::Node.new
      addUSDL(offering, RDF.type, gr.Offering)
      addUSDL(company, gr.offers, offering)
      addUSDL(offering, gr.name , i)
      addTriple(company, @resume_cv.hasSpeciality , i)
    end

    extractAnnotation("distributed_by").each do  |i|
      puts "distfor : #{i}"
      addUSDL(company, @resume_cv.distributed_by, i)
      addTriple(company, @resume_cv.distributed_by, i)
    end

    # addTriple(company , @resume_cv.isIndustry, industry)
    # addUSDL(company, gr.category, industry)
    # addTriple(company, @resume_cv.hasSpeciality, s)
    addTriple(company , @resume_cv.hasWebsite, website)
    addUSDL(company, RDF::FOAF.page, website)
    addTriple( company , @resume_cv.name, company_name)
    addUSDL( company, gr.legalName, company_name)
    #   # addTriple(company , @resume_cv.hasType, type)
    #   # addTriple(company , @resume_cv.wasFounded, founded)
    #   # addTriple(company , @resume_cv.hasSize, compsize)
    address = RDF::Node.new
    addUSDL(address, RDF.type , v.Address)
    addUSDL(company, l.hasCommunicationChannel, address)

    telephone = RDF::Node.new
    addUSDL(telephone, RDF.type, v.Voice)
    addUSDL(telephone, v.hasValue, phone)

    addUSDL(address, v.country_name, country)
    addUSDL(address, v.locality, locality)
    addUSDL(address, v.postal_code, postal )
    addUSDL(address, v.street_address, streetAddress)
    addUSDL(address, v.has_email ,mail)

    addTriple(company , @resume_cv.hasLocality, locality)
    addTriple(company , @resume_cv.hasStreetAddress, streetAddress)
    addTriple(company , @resume_cv.locatedInRegion, region)
    addTriple(company , @resume_cv.postalCode, postal)
    addTriple(company , @resume_cv.country, country)

    add_annotation( "locality", locality)
    add_annotation( "street" , streetAddress)
    add_annotation( "postal"  , postal)
    add_annotation( "country", country)
    add_annotation( "phone", phone)
    add_annotation( "mail" , mail)

    company_name
  end

  def init(content)
    puts "parsing file\n\n"
    @doc = Nokogiri::XML(content)
    @resume_cv = RDF::Vocabulary.new("http://fitman.sti2.at/company/")

    begin
      @annotations  = JSON.parse( IO.read("annotations.json") )
      remove_annotation_duplicates
    rescue
      @annotations = Hash.new
    end
  end


  def remove_annotation_duplicates
    @annotations.select do |k,v|
      v.uniq!
    end
  end

  #############################################################
  # Save the created triples inside a file
  #############################################################
  def returnTriples()
    return @graph.dump(:ntriples)
  end

  def returnUSDL()
    return @graph_usdl.dump(:ntriples)
  end


  def store_wordlists
    remove_annotation_duplicates
    File.open("annotations.json","w") do |f|
      f.write(JSON.pretty_generate(@annotations))
    end

    @annotations.each do |k, v|
      File.open(k,"w") do |f|
        v.each do |word|
          f.write(word.to_s.strip+"\n")
        end
      end
    end
  end

  #############################################################
  # Run the program to
  #############################################################

  def run(content)
    puts "Running company extractor"
    @graph = RDF::Graph.new
    @graph_usdl = RDF::Graph.new

    init(content)

    begin
      @company_name = extractData
    rescue Exception => e
      puts "Extraction failed for company"
      puts e
      @company_name = "failed"
      return "failed"
    end
    puts returnUSDL
    store_wordlists
  end

  def company_name
    @company_name
  end



  def getNodesInRange(type,startPos,endPos)
    nodes = Array.new
    puts "get nodes in #{startPos} - - #{endPos} of #{type}"
    #get all related nodes inbetween
    potentialInbetweenNodes = @doc.xpath("//Annotation[@Type='#{type}']")

    potentialInbetweenNodes.each do |node|
      startNode = node.xpath('@StartNode').first.content
      endNode = node.xpath('@EndNode').first.content

      if startNode >= startPos and endNode <= endPos
        content = ""
        for i in startNode..endNode
          @doc.xpath("//Node[@id=#{i}]").each do |curNode|
            content += curNode.next unless curNode.next.nil?
          end
        end
        nodes.push(content)
      end

    end
    nodes
  end


  def extractAnnotation(annotation)
    puts "retrieve #{annotation}"
    type = annotation
    results = Array.new
    nodes = @doc.xpath("//Annotation[@Type='#{type}']")
    return [nil] unless nodes.size > 0
    nodes.each do |node|
      startNode = node.xpath('@StartNode').first.content
      endNode = node.xpath('@EndNode').first.content
      getNodesInRange(type,startNode,endNode).each do |n|
        results << n.strip
      end
    end
    results.uniq.each do |r|
      add_tag(annotation,r)
    end

    results.uniq
  end

  def add_tag(type, text)
    if text != 'null'
      @es_client.update index: 'tags',type: 'tag', id: 'led_tags', body:
        '{
      "script" : "ctx._source.'+type+' += tag",
      "lang" : "groovy",
          "params" : {
            "tag" : "'+text+'"
     }
   }'
    end
  end
end

puts "Extracting #{ARGV.length} files"

ARGV.each do |file_name|
  puts "Extracting data from #{file_name}"

  extractor = CompanyExtractor.new

  file = File.open(file_name, "r")
  data = file.read
  file.close

  extractor.run data

  file_name = extractor.company_name
  puts "saving to result/#{file_name}"
  File.open( "result/" + file_name + ".rdf", 'w') { |file| file.write(extractor.returnTriples) }
  File.open( "result/" + file_name + ".usdl", 'w') { |file| file.write(extractor.returnUSDL) }

  puts "Finished extracting: #{file_name}"
end
