  module CompanyOntology
    include OntologyCreator
    include Tagger

    @company = nil

    def init_company_ontology
      init_ontology_creator
      init_tags

      @log.info "intializing CompanyOntology"
      #add default annotations to ensure those tags are not empty (so the GATE script won't have to add them)
      add_annotation("distributed_by", "DEFAULT")
      add_annotation("product_categories" , "DEFAULT")
      add_annotation("produces", "DEFAULT")
      add_annotation("distr_category" , "DEFAULT")
      add_annotation("distributes_for" , "DEFAULT")
      add_annotation("provides" , "DEFAULT")
      set_company
      set_up_address
    end

    def self.included(klass)
      klass.send :prepend, CompanyOntology
    end

    def add_extra(extra)
      add_triple(@company, @resume_cv.extra, extra)
      add_usdl(@company, @resume_cv.extra, extra)
    end

    def set_company
      @company = RDF::Node.new
      add_triple( @company , RDF.type, @resume_cv.Company)
      add_usdl(@company, RDF.type, @gr.BusinessEntity)
    end

    def add_produces(product_name)
      product = RDF::Node.new
      add_usdl(product, RDF.type, @gr.ProductOrService)
      add_usdl(product, @gr.name, product_name)
      add_usdl(product, @gr.hasManufacturer, @company)
      add_triple(@company, @resume_cv.produces, product_name)
      add_annotation("product_categories",product_name)
    end

    def add_sells_product(product_name)
      offering = RDF::Node.new
      add_usdl(offering, RDF.type, @gr.Offering)
      add_usdl(@company, @gr.offers, offering)
      add_usdl(offering, @gr.name , product_name)
      add_triple(@company, @resume_cv.sells , product_name)
      add_annotation("produces", product_name)
    end

    def  add_subcategory(category)
      add_usdl(@company, @gr.subcategories, category)
      add_triple(@company, @resume_cv.subcategories, category)
      add_annotation("subcategory", category)
    end

    def  add_category(category)
      add_usdl(@company, @gr.category, category)
      add_triple(@company, @resume_cv.category, category)
      add_annotation("category", category)
    end

    def add_distribution_category(distribution_category)
      add_usdl(@company, @gr.category,distribution_category)
      add_triple(@company, @resume_cv.distribution_type, distribution_category)
      add_annotation("distr_category",distribution_category)
    end

    def add_distributes_for(distributes_for)
      add_usdl(@company, @resume_cv.distribution_for, distributes_for )
      add_triple(@company, @resume_cv.distribution_for, distributes_for)
      add_annotation("distributes_for",distributes_for)
    end

    def add_provides(provides)
      offering = RDF::Node.new
      add_usdl(offering, RDF.type, @gr.Offering)
      add_usdl(@company, @gr.offers, offering)
      add_usdl(offering, @gr.name , provides)
      add_triple(@company, @resume_cv.hasSpeciality , provides)
      add_annotation("provides",provides)
    end

    def add_distributed_by(distributed_by)
      add_usdl(@company, @resume_cv.distributed_by, distributed_by)
      add_triple(@company, @resume_cv.distributed_by, distributed_by)
      add_annotation("distributed_by",distributed_by)
    end

    def add_website(website)
      add_triple(@company , @resume_cv.hasWebsite, website)
      add_usdl(@company, RDF::FOAF.page, website)
      add_annotation("website",website)
    end

    def add_address(address)
      add_triple(@company, @resume_cv.address, address )
      add_usdl(@company, @resume_cv.address, address )
    end

    def add_mail(mail)
      add_triple(@company, @resume_cv.hasMail, mail)
      add_usdl(@address, @v.has_email ,mail)
      add_annotation("mail" , mail)
    end

    def add_locality(locality)
      add_usdl(@address, @v.locality, locality)
      add_triple(@company , @resume_cv.hasLocality, locality)
      add_annotation("locality", locality)
    end

    def add_street_address(streetAddress)
      add_usdl(@address, @v.street_address, streetAddress)
      add_triple(@company , @resume_cv.hasStreetAddress, streetAddress)
      add_annotation("street" , streetAddress)
    end

    def add_name(company_name)
      add_triple(@company , @resume_cv.name, company_name)
      add_usdl(@company, @gr.legalName, company_name)
      add_annotation("name", company_name)
    end

    def set_up_address
        @address = RDF::Node.new
        add_usdl(@address, RDF.type , @v.Address)
        add_usdl(@company, @l.hasCommunicationChannel, @address)
    end

    def add_country_name(country)
      add_triple(@company , @resume_cv.country, country)
      add_usdl(@address, @v.country_name, country)
      add_annotation("country", country)
    end

    def add_postal_code(postal)
      add_usdl(@address, @v.postal_code, postal )
      add_triple(@company , @resume_cv.postalCode, postal)
      add_annotation("postal"  , postal)
    end

    def add_phone(phone)
      telephone = RDF::Node.new
      add_usdl(telephone, RDF.type, @v.Voice)
      add_usdl(telephone, @v.hasValue, phone)
      add_usdl(@company, RDF::FOAF.phone,telephone)
      add_annotation("phone", phone)
    end

    def add_region(region)
      add_triple(@company , @resume_cv.locatedInRegion, region)
      add_annotation("region",region)
    end
  end
