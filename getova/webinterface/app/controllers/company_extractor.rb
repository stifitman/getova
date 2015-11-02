require 'nokogiri'
require 'open-uri'
require 'rdf'
require 'rdf/ntriples'
require 'sparql'


class CompanyExtractor
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
  #############################################################
  # Extract the person data
  #############################################################
  def extractData()

    gr = RDF::Vocabulary.new("http://purl.org/goodrelations/v1#")
    s = RDF::Vocabulary.new("http://schema.org/address")

    company = RDF::Node.new
    addTriple( company , RDF.type, @resume_cv.Company)
    addUSDL(company, RDF.type, gr.BusinessEntity)

    industry = @doc.css('li').select{|industry| industry['class'] == "industry"}
    unless industry[0].nil?
      industry = industry[0].css('p').text
      addTriple(company , @resume_cv.isIndustry, industry)
      addUSDL(company, gr.category, industry)
    end


    specialities = @doc.css('div').select{|spec| spec['class'] == "specialties"}
    unless specialities[0].nil?
      specialities = specialities[0].css('p').text.strip.gsub(/\s+/, " ").split(',')
      specialities.each do |s|
        speciality = RDF::Node.new
        if (s[0]==" ")
          s = s[1,s.length] #remove whitespace at the beginning
        end
        addTriple(company, @resume_cv.hasSpeciality, s)
      end
    end

    website = @doc.css('li').select{|website| website['class'] == "website"}
    unless website[0].nil?
      website = website[0].css('p').text.chomp.gsub(/\s+/, "")
      addTriple(company , @resume_cv.hasWebsite, website)
      addUSDL(company, RDF::FOAF.page, website)
    end

    addTriple( company , @resume_cv.name, @company_name)
    addUSDL( company, gr.legalName, @company_name)


    type = @doc.css('li').select{|type| type['class'] == "type"}
    unless type[0].nil?
      type = type[0].css('p').text.chomp.gsub(/\s+/, "")
      addTriple(company , @resume_cv.hasType, type)
    end


    founded = @doc.css('li').select{|founded| founded['class'] == "founded"}
    unless founded[0].nil?
      founded = founded[0].css('p').text.chomp.gsub(/\s+/, "")
      addTriple(company , @resume_cv.wasFounded, founded)
    end

    compsize = @doc.css('li').select{|compsize| compsize['class'] == "company-size"}
    unless compsize[0].nil?
      compsize = compsize[0].css('p').text.chomp.gsub(/\s+/, "")
      addTriple(company , @resume_cv.hasSize, compsize)
    end

    address = RDF::Node.new
    addUSDL(address, RDF.type, s.PostalAddress)
    usdlLocality = ""

    locality = @doc.css('span').select{|locality| locality['class'] == "locality"}
    unless locality[0].nil?
      locality = locality[0].text.chomp.gsub(/\s+/, "")
      addTriple(company , @resume_cv.hasLocality, locality)
      usdlLocality += locality
    end


    streetAddress = @doc.css('span').select{|address| address['class'] == "street-address"}
    unless streetAddress[0].nil?
      streetAddress = streetAddress[0].text.chomp.gsub(/\s+/, " ")
      addTriple(company , @resume_cv.hasStreetAddress, streetAddress)
      addUSDL(address , s.streetAddress, streetAddress)
    end

    region = @doc.css('abbr').select{|region| region['class'] == "region"}
    unless region[0].nil?
      region = region[0].text.chomp.gsub(/\s+/, " ")
      addTriple(company , @resume_cv.locatedInRegion, region)
      usdlLocality += ", " if usdlLocality.length > 1
      usdlLocality += region
    end


    postal = @doc.css('span').select{|postal| postal['class'] == "postal-code"}
    unless postal[0].nil?
      postal = postal[0].text.chomp.gsub(/\s+/, " ")
      addTriple(company , @resume_cv.postalCode, postal)
      addUSDL(address , s.postalCode, postal)
    end

    country = @doc.css('span').select{|country| country['class'] == "country-name"}
    unless country[0].nil?
      country = country[0].text.chomp.gsub(/\s+/, " ")
      addTriple(company , @resume_cv.country, country)
      usdlLocality += ", " if usdlLocality.length > 1
      usdlLocality += country
    end


      addUSDL(address , s.addressLocality, usdlLocality)
  end

  def init(content)
    puts "parsing file\n\n"
    @doc = Nokogiri::XML(content)
    puts "GOT CONTENT: #{@doc}"
    @namespace = "htttp://sti2.at/test/"
    @resume_cv = RDF::Vocabulary.new("http://fitman.sti2.at/company/")
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

  #############################################################
  # Run the program to
  #############################################################

  def run(content, name)
    puts "Running company extractor"
    @company_name = name
    @graph = RDF::Graph.new
    @graph_usdl = RDF::Graph.new
    init(content)
    extractData()
    return returnTriples()
  end

end
