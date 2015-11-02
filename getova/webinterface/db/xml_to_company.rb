require 'nokogiri'
require 'open-uri'
require 'rdf'
require 'rdf/ntriples'
require 'sparql'

class StoreXml

  puts "StoreXML loaded"

  #adds triples to the rdf graph
  def addTriple(subject,predicat,object)
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

  #############################################################
  # Extract the person data
  #############################################################
  def extractData()

    @doc.xpath("/ArrayOfMember/Member").each do |company|

      @graph = RDF::Graph.new
      @graph_usdl  = RDF::Graph.new

      legalname = company.xpath("LegalName").text + "\n"
      description =  company.xpath("Description").text + "\n"
      website =  company.xpath("Website").text + "\n"
      legaladdress =  company.xpath("LegalAddress").text + "\n"
      hqaddress =  company.xpath("HQAddress").text + "\n"

      company = RDF::Node.new
      addTriple(company, @resume_cv.hasLegalName, legalname)
      addTriple(company, @resume_cv.hasDescription, description)
      addTriple(company, @resume_cv.hasWebsite, website)
      addTriple(company, @resume_cv.hasLegalAddress, legaladdress)
      addTriple(company, @resume_cv.hasHQAddress, hqaddress)


      gr = RDF::Vocabulary.new("http://purl.org/goodrelations/v1#")
      s = RDF::Vocabulary.new("http://schema.org/address#")
      addUSDL( company, gr.legalName, legalname)
      addUSDL(company, RDF::FOAF.page, website)

      company_ws = Hash.new
      company_ws[:name] = legalname
      company_ws[:content] = @graph.dump(:ntriples)
      company_ws[:usdl]  = @graph_usdl.dump(:ntriples)
      jsonld = getJsonld(company_ws[:usdl]).to_json
      company_ws[:jsonld] =  "#{jsonld.to_json}"

      puts "added company #{legalname}"
      Company.create(company_ws)
    end
  end

  def init(file)
    puts "parsing file\n\n"
    @doc = Nokogiri::XML(open(file))
    @namespace = "htttp://sti2.at/test/"
    @resume_cv = RDF::Vocabulary.new("http://fitman.sti2.at/company/")
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



  #############################################################
  # Run the program to
  #############################################################

  def run(arg)
    init(arg)
    extractData()
  end
end


