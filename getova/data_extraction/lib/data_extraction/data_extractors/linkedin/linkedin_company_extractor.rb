module LinkedInExtraction
  class CompanyExtractor < Tagger::DataExtractor

    def extract_data
      company = RDF::Node.new
      add_triple( company , RDF.type, @resume_cv.Company)

      industry = @doc.css('li').select{|industry| industry['class'] == "industry"}
      unless industry[0].nil?
        industry = industry[0].css('p').text
        add_triple(company , @resume_cv.isIndustry, industry)
      end

      specialities = @doc.css('div').select{|spec| spec['class'] == "specialties"}
      unless specialities[0].nil?
        specialities = specialities[0].css('p').text.strip.gsub(/\s+/, " ").split(',')
        specialities.each do |s|
          speciality = RDF::Node.new
          if (s[0]==" ")
            s = s[1,s.length] #remove whitespace at the beginning
          end
          add_triple(company, @resume_cv.hasSpeciality, s)
        end
      end

      website = @doc.css('li').select{|website| website['class'] == "website"}
      unless website[0].nil?
        website = website[0].css('p').text.chomp.gsub(/\s+/, "")
        add_triple(company , @resume_cv.hasWebsite, website)

        name = website
      else
        name = ""
      end

      add_triple( company , @resume_cv.name, name)

      type = @doc.css('li').select{|type| type['class'] == "type"}
      unless type[0].nil?
        type = type[0].css('p').text.chomp.gsub(/\s+/, "")
        add_triple(company , @resume_cv.hasType, type)
      end

      founded = @doc.css('li').select{|founded| founded['class'] == "founded"}
      unless founded[0].nil?
        founded = founded[0].css('p').text.chomp.gsub(/\s+/, "")
        add_triple(company , @resume_cv.wasFounded, founded)
      end

      compsize = @doc.css('li').select{|compsize| compsize['class'] == "company-size"}
      unless compsize[0].nil?
        compsize = compsize[0].css('p').text.chomp.gsub(/\s+/, "")
        add_triple(company , @resume_cv.hasSize, compsize)
      end

      locality = @doc.css('span').select{|locality| locality['class'] == "locality"}
      unless locality[0].nil?
        locality = locality[0].text.chomp.gsub(/\s+/, "")
        add_triple(company , @resume_cv.hasLocality, locality)
      end

      streetAddress = @doc.css('span').select{|address| address['class'] == "street-address"}
      unless streetAddress[0].nil?
        streetAddress = streetAddress[0].text.chomp.gsub(/\s+/, " ")
        add_triple(company , @resume_cv.hasStreetAddress, streetAddress)
      end

      region = @doc.css('abbr').select{|region| region['class'] == "region"}
      unless region[0].nil?
        region = region[0].text.chomp.gsub(/\s+/, " ")
        add_triple(company , @resume_cv.locatedInRegion, region)
      end

      postal = @doc.css('span').select{|postal| postal['class'] == "postal-code"}
      unless postal[0].nil?
        postal = postal[0].text.chomp.gsub(/\s+/, " ")
        add_triple(company , @resume_cv.postalCode, postal)
      end

      country = @doc.css('span').select{|country| country['class'] == "country-name"}
      unless country[0].nil?
        country = country[0].text.chomp.gsub(/\s+/, " ")
        add_triple(company , @resume_cv.country, country)
      end
    end
  end
end
