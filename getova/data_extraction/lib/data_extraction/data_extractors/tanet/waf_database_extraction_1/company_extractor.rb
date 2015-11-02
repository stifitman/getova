module WAFExtraction1
  class CompanyExtractor < Tagger::DataExtractor


    def start extractor_name
      @xpath_splitter = "/ArrayOfMember/Member"
      super extractor_name
    end

    def extract_data
      legalname = @doc.xpath("LegalName").text + "\n"
      description =  @doc.xpath("Description").text + "\n"
      website =  @doc.xpath("Website").text + "\n"
      legaladdress =  @doc.xpath("LegalAddress").text + "\n"
      hqaddress =  @doc.xpath("HQAddress").text + "\n"

      company = RDF::Node.new
      add_triple(company, @resume_cv.hasLegalName, legalname)
      add_triple(company, @resume_cv.hasDescription, description)
      add_triple(company, @resume_cv.hasWebsite, website)
      add_triple(company, @resume_cv.hasLegalAddress, legaladdress)
      add_triple(company, @resume_cv.hasHQAddress, hqaddress)
      add_triple(company, @resume_cv.extra, "tanet")

      return legalname.gsub('/','_')
    end
  end
end
